#!/bin/bash

# shell script to create a basic VM using the Prism v3 REST API
# requires the existence of a JSON-formatted file that contains:
#
# cluster/CVM IP
# username
# the name of the VM to be created
#
# this file must be named "create_vm_v3_basic.json" and be formatted as follows:
#
# {"cluster_ip":"10.0.0.1","username":"admin","vm_name":"BasicVMViaAPIv3"}

JSON_FILE="./create_vm_v3_basic.json"
JSON_CONTENTS="`cat ${JSON_FILE}`"

JQ=`command -v jq`
CURL=`command -v curl`

#IMAGE_SC=`curl -s --user admin:nx2Tech123! -k -X GET --header "Content-Type: application/json" --header "Accept: application/json" "https://10.55.67.37:9440/api/nutanix/v2.0/storage_containers/"| jq '.entities[] | {name: .name, uuid: .storage_container_uuid} | select (.name | . and contains("Images"))' | grep uuid | awk -F\" {'print$4'}`

#echo Destination Container: $IMAGE_SC

if [ "$JQ" = "" ] || [ "$CURL" = "" ]; then
    echo "jq command not found."
else
    CLUSTER_IP=`echo -n $JSON_CONTENTS | jq -r ".cluster_ip"`
    USERNAME=`echo -n $JSON_CONTENTS | jq -r ".username"`
    VM_NAME=`echo -n $JSON_CONTENTS | jq -r ".vm_name"`
    PASSWORD=`echo -n $JSON_CONTENTS | jq -r ".passwd"`
    CONTAINER=`echo -n $JSON_CONTENTS | jq -r ".container"`

    # get the password from the user
    #echo "Please enter your cluster password (will not be shown on screen):"
    #read -s PASSWORD

    # generate the HTTP Basic Authorization header
    AUTH_HEADER="`echo -n $USERNAME:$PASSWORD | base64`"

   #Get the storage container uuid
   IMAGE_SC=`curl -s --user admin:nx2Tech123! -k -X GET --header "Content-Type: application/json" --header "Accept: application/json" "https://$CLUSTER_IP:9440/api/nutanix/v2.0/storage_containers/"| jq '.entities[] | {name: .name, uuid: .storage_container_uuid} | select (.name | . and contains("'"$CONTAINER"'"))' | grep uuid | awk -F\" {'print$4'}`

   #Get the image uuid
   IMAGE_UUID=`curl -s -k -X GET --header "Content-Type: application/json" --header "Accept: application/json" -H "Authorization: Basic $AUTH_HEADER" "https://$CLUSTER_IP:9440/api/nutanix/v0.8/images/"| jq '.entities[] | select (.name=="fedora-coreos")'|grep uuid|awk -F\" {'print $4'}`

echo "Destination Container: $IMAGE_SC"
echo "Image uuid: $IMAGE_UUID"




    # submit the request
curl --insecure --basic -k -T "/root/fcos/fedora-coreos-31.20200505.3.0-qemu.x86_64.qcow2" -X PUT \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Basic $AUTH_HEADER" \
  -H "X-Nutanix-Destination-Container:$IMAGE_SC" "https://$CLUSTER_IP:9440/api/nutanix/v0.8/images/$IMAGE_UUID/upload"

fi
