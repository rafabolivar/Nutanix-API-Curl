#/!bin/bash
curl -k -s --request PUT \
  --url https://10.42.99.37:9440/PrismGateway/services/rest/v2.0/vms/26c04459-3691-483f-8b9b-0010b9a8ff23/disks/update \
  --header 'authorization: Basic YWRtaW46bngyVGVjaDEyMyE=' \
  --header 'content-type: application/json' \
  --data '{"vm_disks":[{"disk_address":{"vmdisk_uuid":"ee1d95a4-02f6-4f83-b80b-579cb189a244","device_uuid":"8b50042d-0365-4810-9fca-6a03410a7e74","device_index":0,"device_bus":"scsi"},"flash_mode_enabled":false,"is_cdrom":false,"is_empty":false,"vm_disk_create":{"storage_container_uuid":"4d147c07-188a-4b54-82a1-bbd5c733e69c","size":99000000000}}]}'
