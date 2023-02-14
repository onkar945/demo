


Instance Metadata service provides information regarding your running virtual machine instances. This information can be used to manage and configure your instances on Azure. Azure's instance metadata service is a RESTful endpoint available to all IaaS VMs created via new [Azure Resource Manager](https://docs.microsoft.com/en-us/rest/api/resources/?redirectedfrom=MSDN). The endpoint is available at a well-known non routable IP address (*169.254.169.254*) that can be accessed only from within the VM. This service would provide important data regarding virtual machine instance, its network configuration, 



## Retrieving Linux instance metadata 

Instance metadata is available for running VMs created/managed using [Azure Resource Manager](https://docs.microsoft.com/en-us/rest/api/resources/?redirectedfrom=MSDN). 
Access all data categories for an instance use the following URI

```
$ curl -H Metadata:true http://169.254.169.254/metadata/instance?api-version=2021-02-01
```

The default output for all instance metadata is of json format(content type Application/JSON)

## Usage Examples
Following are set of examples and usage semantics for instance metadata service

### Versioning 
Instance metadata service is versioned. Versions are mandatory and the current version is 2021-02-01.


```
curl -H Metadata:true http://169.254.169.254/metadata/instance?api-version=2021-02-01
```

As we add newer versions, earlier version is made available in case your scripts has dependencies on data formats.


### Data output
By default instance metadata returns data in JSON (content type=application/json).Different node elements can return data in different default format as applicable, following table is a quick reference for data formats 

Element | default data format | Other formats
--------|---------------------|--------------
/instance | Json | text
/scheduledevents | Json | None

For text format use format=text in the request URL, for example 
#### Retrieving the network information 

```
curl -H Metadata:true http://169.254.169.254/metadata/instance/network?api-version=2017-03-01

{
  "interface": [
    {
      "ipv4": {
        "ipaddress": [
          {
            "ipaddress": "10.0.0.4",
            "publicip": "<>.<>.<>.<>"
          }
        ],
        "subnet": [
          {
            "address": "10.0.0.0",
            "dnsservers": [
              {
                "ipaddress": "10.0.0.2"
              },
              {
                "ipaddress": "10.0.0.3"
              }
            ],
            "prefix": "24"
          }
        ]
      },
      "ipv6": {
        "ipaddress": []
      },
      "mac": "000D3A00FA89"
    }
  ]
}
```

#### Retrieving public IP address

```
curl -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipaddress/0/publicip?api-version=2017-03-01&format=text"
```

#### Retrieving all instance metadata 

```
curl -H Metadata:true http://169.254.169.254/metadata/instance?api-version=2017-03-01

{
"compute": {
    "location": "CentralUS",
    "name": "IMDSCanary",
    "offer": "RHEL",
    "osType": "Linux",
    "platformFaultDomain": "0",
    "platformUpdateDomain": "0",
    "publisher": "RedHat",
    "sku": "7.2",
    "version": "7.2.20161026",
    "vmId": "5c08b38e-4d57-4c23-ac45-aca61037f084",
    "vmSize": "Standard_DS2"
  },
  "network": {
    "interface": [
      {
        "ipv4": {
          "ipaddress": [
            {
              "ipaddress": "10.0.0.4",
              "publicip": "X.X.X.X"
            }
          ],
          "subnet": [
            {
              "address": "10.0.0.0",
              "dnsservers": [
                {
                  "ipaddress": "10.0.0.2"
                },
                {
                  "ipaddress": "10.0.0.3"
                }
              ],
              "prefix": "24"
            }
          ]
        },
        "ipv6": {
          "ipaddress": []
        },
        "mac": "000D3A00FA89"
      }
    ]
  }
}

```

## Retrieving Windows instance metadata 

filter to the first element from the Network.interface property and return:

```
http://169.254.169.254/metadata/instance/network/interface/0?api-version=<version>
```

```
 Expected outcome:
 
{
    "ipv4": {
       "ipAddress": [{
            "privateIpAddress": "10.144.133.132",
            "publicIpAddress": ""
        }],
        "subnet": [{
            "address": "10.144.133.128",
            "prefix": "26"
        }]
    },
    "ipv6": {
        "ipAddress": [
         ]
    }
    },

    ```