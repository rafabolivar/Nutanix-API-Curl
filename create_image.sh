#!/bin/bash

# shell script to create an Image using the Prism v0.8 REST API
# requires the existence of a JSON-formatted file that contains:
#
# cluster/CVM IP
# username
# the password for Prism Element
# the container where the image will be created (tipically Images) Case Sensitive
# the image name
#
# this file must be named "create_image.json" and be formatted as follows:
# {"cluster_ip":"10.55.67.37","username":"admin","passwd":"nx2Tech123!","container":"Images","image_name":"fedora-coreos"}

JSON_FILE="./create_image.json"
JSON_CONTENTS="`cat ${JSON_FILE}`"

JQ=`command -v jq`
CURL=`command -v curl`

if [ "$JQ" = "" ] || [ "$CURL" = "" ]; then
    echo "jq command not found."
else
    CLUSTER_IP=`echo -n $JSON_CONTENTS | jq -r ".cluster_ip"`
    USERNAME=`echo -n $JSON_CONTENTS | jq -r ".username"`
    PASSWORD=`echo -n $JSON_CONTENTS | jq -r ".passwd"`
    CONTAINER=`echo -n $JSON_CONTENTS | jq -r ".container"`
    IMAGE_NAME=`echo -n $JSON_CONTENTS | jq -r ".image_name"`

    # get the password from the user
    #echo "Please enter your cluster password (will not be shown on screen):"
    #read -s PASSWORD

    # generate the HTTP Basic Authorization header
    AUTH_HEADER="`echo -n $USERNAME:$PASSWORD | base64`"


   #Create the image
   curl --insecure --basic -X POST \
        --connect-timeout 5 \
        https://$CLUSTER_IP:9440/api/nutanix/v0.8/images \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -H "Authorization: Basic $AUTH_HEADER" \
        -H "cache-control: no-cache" \
        -d '{"name": "fedora-coreos", "annotation": "", "imageType": "DISK_IMAGE"}'

   #Get the storage container uuid
   IMAGE_SC=`curl -s -k -X GET \
                  -H "Content-Type: application/json" \
                  -H "Accept: application/json" \
                  -H "Authorization: Basic $AUTH_HEADER" \
                  "https://$CLUSTER_IP:9440/api/nutanix/v2.0/storage_containers/"| jq '.entities[] | {name: .name, uuid: .storage_container_uuid} | select (.name | . and contains("'"$CONTAINER"'"))' | grep uuid | awk -F\" {'print$4'}`

   #Get the image uuid
   IMAGE_UUID=`curl -s -k -X GET \
                    -H "Content-Type: application/json" \
                    -H "Accept: application/json" \
                    -H "Authorization: Basic $AUTH_HEADER" \
                    "https://$CLUSTER_IP:9440/api/nutanix/v0.8/images/"| jq '.entities[] | select (.name=="'"$IMAGE_NAME"'")'|grep uuid|awk -F\" {'print $4'}`

echo "Destination Container: $IMAGE_SC"
echo "Image name: $IMAGE_NAME"
echo "Image uuid: $IMAGE_UUID"


    # submit the request
  curl --insecure --basic -k -T "/home/centos/fcos/fedora-coreos.qcow2" -X PUT \
       -H "Content-Type: application/json" \
       -H "Accept: application/json" \
       -H "Authorization: Basic $AUTH_HEADER" \
       -H "X-Nutanix-Destination-Container:$IMAGE_SC" "https://$CLUSTER_IP:9440/api/nutanix/v0.8/images/$IMAGE_UUID/upload"

fi
