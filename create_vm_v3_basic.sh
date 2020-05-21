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

if [ "$JQ" = "" ] || [ "$CURL" = "" ]; then
    echo "jq command not found."
else
    CLUSTER_IP=`echo -n $JSON_CONTENTS | jq -r ".cluster_ip"`
    USERNAME=`echo -n $JSON_CONTENTS | jq -r ".username"`
    VM_NAME=`echo -n $JSON_CONTENTS | jq -r ".vm_name"`
    PASSWORD=`echo -n $JSON_CONTENTS | jq -r ".passwd"`


    # get the password from the user
    #echo "Please enter your cluster password (will not be shown on screen):"
    #read -s PASSWORD

    # generate the HTTP Basic Authorization header
    AUTH_HEADER="`echo -n $USERNAME:$PASSWORD | base64`"

    # submit the request
    curl --insecure --basic -X POST \
        --connect-timeout 5 \
    https://$CLUSTER_IP:9440/api/nutanix/v3/vms \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic $AUTH_HEADER" \
  -H "cache-control: no-cache" \
  -d "{
        \"spec\":{
                \"name\":\"$VM_NAME\",
                \"resources\":{
                }
        },
        \"metadata\":{
                \"kind\":\"vm\"
        }
      }"

fi
