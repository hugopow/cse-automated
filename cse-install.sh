#!/bin/sh
# Script to install and configure Container Service Extension 3.1.2

# Update Photon repositories
echo "Update Photon public repositories"
cd /etc/yum.repos.d/
sed  -i 's/dl.bintray.com\/vmware/packages.vmware.com\/photon\/$releasever/g' photon.repo photon-updates.repo photon-extras.repo photon-debuginfo.repo
 
# Update Photon
echo "Update Photon"
tdnf --assumeyes update

# Install dependencies
echo "Install CSE dependencies"
tdnf --assumeyes install build-essential python3-devel python3-pip git
 
# Update python3, cse supports python3 version 3.7.3 or greater, it does not support python 3.8 or above.
echo " Update Python3"
tdnf --assumeyes update python3

# Prepare cse user and application directories
echo "Prepare cse user and application directories"
mkdir -p /opt/vmware
chmod 775 -R /opt
groupadd cse
useradd cse -g cse -m -p Vmware1! -d /opt/vmware/cse
chown cse:cse -R /opt

# Run as cse user
echo "Run as cse user"
su - cse

# (Optional) Add your public ssh key to CSE server to login to the CSE server with your SSH key pair
echo "Add your public ssh key to CSE server"
mkdir -p ~/.ssh
cat >> ~/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAhcw67bz3xRjyhPLysMhUHJPhmatJkmPUdMUEZre+MeiDhC602jkRUNVu43Nk8iD/I07kLxdAdVPZNoZuWE7WBjmn13xf0Ki2hSH/47z3ObXrd8Vleq0CXa+qRnCeYM3FiKb4D5IfL4XkHW83qwp8PuX8FHJrXY8RacVaOWXrESCnl3cSC0tA3eVxWoJ1kwHxhSTfJ9xBtKyCqkoulqyqFYU2A1oMazaK9TYWKmtcYRn27CC1Jrwawt2zfbNsQbHx1jlDoIO6FLz8Dfkm0DToanw0GoHs2Q+uXJ8ve/oBs0VJZFYPquBmcyfny4WIh4L0lwzsiAVWJ6PvzF5HMuNcwQ== rsa-key-20210508
EOF

# Create a bash profile for CSE
cat >> ~/.bash_profile << EOF
# For Container Service Extension
export CSE_CONFIG=/opt/vmware/cse/config/config.yaml
export CSE_CONFIG_PASSWORD=Vmware1!
source /opt/vmware/cse/python/bin/activate
EOF

# Install CSE in virtual environment
echo "Install CSE"
python3 -m venv /opt/vmware/cse/python
source /opt/vmware/cse/python/bin/activate
echo "Update pip3"
python3 -m pip install --upgrade pip
pip3 install container-service-extension

echo "The CSE version is"
cse version

source ~/.bash_profile

# Prepare vcd-cli
echo "Prepare vcd-cli"
mkdir -p ~/.vcd-cli
cat >  ~/.vcd-cli/profiles.yaml << EOF
extensions:
- container_service_extension.client.cse
EOF

echo "The vcd-cli cse version is"
vcd cse version

# (Optional) Add my Let's Encrypt intermediate and root certs. Use your certificates issued by your CA to enable verify=true with CSE.
echo "Add Intermediate and Root certificates to trusted certificates."
cat >> /opt/vmware/cse/python/lib/python3.7/site-packages/certifi/cacert.pem << EOF
-----BEGIN CERTIFICATE-----
MIIFFjCCAv6gAwIBAgIRAJErCErPDBinU/bWLiWnX1owDQYJKoZIhvcNAQELBQAw
TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwHhcNMjAwOTA0MDAwMDAw
WhcNMjUwOTE1MTYwMDAwWjAyMQswCQYDVQQGEwJVUzEWMBQGA1UEChMNTGV0J3Mg
RW5jcnlwdDELMAkGA1UEAxMCUjMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
AoIBAQC7AhUozPaglNMPEuyNVZLD+ILxmaZ6QoinXSaqtSu5xUyxr45r+XXIo9cP
R5QUVTVXjJ6oojkZ9YI8QqlObvU7wy7bjcCwXPNZOOftz2nwWgsbvsCUJCWH+jdx
sxPnHKzhm+/b5DtFUkWWqcFTzjTIUu61ru2P3mBw4qVUq7ZtDpelQDRrK9O8Zutm
NHz6a4uPVymZ+DAXXbpyb/uBxa3Shlg9F8fnCbvxK/eG3MHacV3URuPMrSXBiLxg
Z3Vms/EY96Jc5lP/Ooi2R6X/ExjqmAl3P51T+c8B5fWmcBcUr2Ok/5mzk53cU6cG
/kiFHaFpriV1uxPMUgP17VGhi9sVAgMBAAGjggEIMIIBBDAOBgNVHQ8BAf8EBAMC
AYYwHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMBMBIGA1UdEwEB/wQIMAYB
Af8CAQAwHQYDVR0OBBYEFBQusxe3WFbLrlAJQOYfr52LFMLGMB8GA1UdIwQYMBaA
FHm0WeZ7tuXkAXOACIjIGlj26ZtuMDIGCCsGAQUFBwEBBCYwJDAiBggrBgEFBQcw
AoYWaHR0cDovL3gxLmkubGVuY3Iub3JnLzAnBgNVHR8EIDAeMBygGqAYhhZodHRw
Oi8veDEuYy5sZW5jci5vcmcvMCIGA1UdIAQbMBkwCAYGZ4EMAQIBMA0GCysGAQQB
gt8TAQEBMA0GCSqGSIb3DQEBCwUAA4ICAQCFyk5HPqP3hUSFvNVneLKYY611TR6W
PTNlclQtgaDqw+34IL9fzLdwALduO/ZelN7kIJ+m74uyA+eitRY8kc607TkC53wl
ikfmZW4/RvTZ8M6UK+5UzhK8jCdLuMGYL6KvzXGRSgi3yLgjewQtCPkIVz6D2QQz
CkcheAmCJ8MqyJu5zlzyZMjAvnnAT45tRAxekrsu94sQ4egdRCnbWSDtY7kh+BIm
lJNXoB1lBMEKIq4QDUOXoRgffuDghje1WrG9ML+Hbisq/yFOGwXD9RiX8F6sw6W4
avAuvDszue5L3sz85K+EC4Y/wFVDNvZo4TYXao6Z0f+lQKc0t8DQYzk1OXVu8rp2
yJMC6alLbBfODALZvYH7n7do1AZls4I9d1P4jnkDrQoxB3UqQ9hVl3LEKQ73xF1O
yK5GhDDX8oVfGKF5u+decIsH4YaTw7mP3GFxJSqv3+0lUFJoi5Lc5da149p90Ids
hCExroL1+7mryIkXPeFM5TgO9r0rvZaBFOvV2z0gp35Z0+L4WPlbuEjN/lxPFin+
HlUjr8gRsI3qfJOQFy/9rKIJR0Y/8Omwt/8oTWgy1mdeHmmjk7j1nYsvC9JSQ6Zv
MldlTTKB3zhThV1+XWYp6rjd5JW1zbVWEkLNxE7GJThEUG3szgBVGP7pSWTUTsqX
nLRbwHOoq7hHwg==
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIFazCCA1OgAwIBAgIRAIIQz7DSQONZRGPgu2OCiwAwDQYJKoZIhvcNAQELBQAw
TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwHhcNMTUwNjA0MTEwNDM4
WhcNMzUwNjA0MTEwNDM4WjBPMQswCQYDVQQGEwJVUzEpMCcGA1UEChMgSW50ZXJu
ZXQgU2VjdXJpdHkgUmVzZWFyY2ggR3JvdXAxFTATBgNVBAMTDElTUkcgUm9vdCBY
MTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAK3oJHP0FDfzm54rVygc
h77ct984kIxuPOZXoHj3dcKi/vVqbvYATyjb3miGbESTtrFj/RQSa78f0uoxmyF+
0TM8ukj13Xnfs7j/EvEhmkvBioZxaUpmZmyPfjxwv60pIgbz5MDmgK7iS4+3mX6U
A5/TR5d8mUgjU+g4rk8Kb4Mu0UlXjIB0ttov0DiNewNwIRt18jA8+o+u3dpjq+sW
T8KOEUt+zwvo/7V3LvSye0rgTBIlDHCNAymg4VMk7BPZ7hm/ELNKjD+Jo2FR3qyH
B5T0Y3HsLuJvW5iB4YlcNHlsdu87kGJ55tukmi8mxdAQ4Q7e2RCOFvu396j3x+UC
B5iPNgiV5+I3lg02dZ77DnKxHZu8A/lJBdiB3QW0KtZB6awBdpUKD9jf1b0SHzUv
KBds0pjBqAlkd25HN7rOrFleaJ1/ctaJxQZBKT5ZPt0m9STJEadao0xAH0ahmbWn
OlFuhjuefXKnEgV4We0+UXgVCwOPjdAvBbI+e0ocS3MFEvzG6uBQE3xDk3SzynTn
jh8BCNAw1FtxNrQHusEwMFxIt4I7mKZ9YIqioymCzLq9gwQbooMDQaHWBfEbwrbw
qHyGO0aoSCqI3Haadr8faqU9GY/rOPNk3sgrDQoo//fb4hVC1CLQJ13hef4Y53CI
rU7m2Ys6xt0nUW7/vGT1M0NPAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNV
HRMBAf8EBTADAQH/MB0GA1UdDgQWBBR5tFnme7bl5AFzgAiIyBpY9umbbjANBgkq
hkiG9w0BAQsFAAOCAgEAVR9YqbyyqFDQDLHYGmkgJykIrGF1XIpu+ILlaS/V9lZL
ubhzEFnTIZd+50xx+7LSYK05qAvqFyFWhfFQDlnrzuBZ6brJFe+GnY+EgPbk6ZGQ
3BebYhtF8GaV0nxvwuo77x/Py9auJ/GpsMiu/X1+mvoiBOv/2X/qkSsisRcOj/KK
NFtY2PwByVS5uCbMiogziUwthDyC3+6WVwW6LLv3xLfHTjuCvjHIInNzktHCgKQ5
ORAzI4JMPJ+GslWYHb4phowim57iaztXOoJwTdwJx4nLCgdNbOhdjsnvzqvHu7Ur
TkXWStAmzOVyyghqpZXjFaH3pO3JLF+l+/+sKAIuvtd7u+Nxe5AW0wdeRlN8NwdC
jNPElpzVmbUq4JUagEiuTDkHzsxHpFKVK7q4+63SM1N95R1NbdWhscdCb+ZAJzVc
oyi3B43njTOQ5yOf+1CceWxG1bQVs5ZufpsMljq4Ui0/1lvh+wjChP4kqKOJ2qxq
4RgqsahDYVvTH9w7jXbyLeiNdd8XM2w9U/t7y0Ff/9yi0GE44Za4rF2LN9d11TPA
mRGunUHBcnWEvgJBQl9nJEiU0Zsnvgc/ubhPgXRR4Xq37Z0j4r7g1SgEEzwxA57d
emyPxgcYxn/eR44/KJ4EBs+lVDR3veyJm+kXQ99b21/+jh5Xos1AnX5iItreGCc=
-----END CERTIFICATE-----
EOF

# Create service account, if already done previously then comment this section out.
#vcd login vcd.vmwire.com system administrator -p Vmware1!
#cse create-service-role vcd.vmwire.com
# Enter system administrator username and password
 
# Create VCD service account for CSE, if already done previously then comment this section out.
#vcd user create --enabled svc-cse Vmware1! "CSE Service Role"

# Create config file directory
echo "Create config file directory"
mkdir -p /opt/vmware/cse/config

# Setup the CSE config file, make your changes to suit your environment
cat > /opt/vmware/cse/config-not-encrypted.conf << EOF
mqtt:
  verify_ssl: false
 
vcd:
  host: vcd.vmwire.com
  log: true
  password: Vmware1!
  port: 443
  username: svc-cse
  verify: true
 
vcs:
- name: vcenter.vmwire.com
  password: Vmware1!
  username: administrator@vsphere.local
  verify: true
 
service:
  enforce_authorization: false
  legacy_mode: false
  log_wire: false
  no_vc_communication_mode: false
  processors: 15
  telemetry:
    enable: true
 
broker:
  catalog: cse-catalog
  ip_allocation_mode: pool
  network: default-organization-network
  org: cse
  remote_template_cookbook_url: https://raw.githubusercontent.com/vmware/container-service-extension-templates/master/template_v2.yaml
  storage_profile: 'iscsi'
  vdc: cse-vdc
EOF

# Prepare the config file
echo "Encrypt the config file"
cse encrypt /opt/vmware/cse/config-not-encrypted.conf --output /opt/vmware/cse/config/config.yaml
chmod 600 /opt/vmware/cse/config/config.yaml
echo "Check the config file is valid"
cse check /opt/vmware/cse/config/config.yaml

# List current imported templates in CSE
echo "List current imported templates in CSE"
cse template list

# Import TKGm ova with this command, uncomment below if you have NOT already imported any TKGm templates with the command below.
# Note that you cannot just import these templates into VCD using VCD, you must do this using the cse template import command.
# Copy the ova to /tmp/ first, the ova can be obtained from my.vmware.com, ensure that it has chmod 644 permissions.
# cse template import -F /tmp/ubuntu-2004-kube-v1.20.5-vmware.2-tkg.1-6700972457122900687.ova
 
# You may need to enable 644 permissions on the file if CSE complains that the file is not readable.
 
# Install CSE
cse install
 
# (Optional) Or use this if you've already installed and want to skip template creation again
# cse upgrade
 
# (Optional) Register the cse extension with vcd if it did not already register
# vcd system extension create cse cse cse vcdext '/api/cse, /api/cse/.*, /api/cse/.*/.*'
 
# Setup cse.sh for the service to use
cat > /opt/vmware/cse/cse.sh << EOF
#!/usr/bin/env bash
source /opt/vmware/cse/python/bin/activate
export CSE_CONFIG=/opt/vmware/cse/config/config.yaml
export CSE_CONFIG_PASSWORD=Vmware1!
cse run
EOF
 
# Make cse.sh executable
chmod +x /opt/vmware/cse/cse.sh
 
# Deactivate the python virtual environment and go back to root
deactivate
exit

# Setup cse.service, use MQTT and not RabbitMQ # In VMs only
cat > /etc/systemd/system/cse.service << EOF
[Unit]
Description=Container Service Extension for VMware Cloud Director
 
[Service]
ExecStart=/opt/vmware/cse/cse.sh
User=cse
WorkingDirectory=/opt/vmware/cse
Type=simple
Restart=always
 
[Install]
WantedBy=default.target
EOF
 
systemctl enable cse.service
systemctl start cse.service
 
systemctl status cse.service

# Tail the logs
echo "Show CSE logs"
tail -f /opt/vmware/cse/.cse-logs/cse-server-info.log -f /opt/vmware/cse/.cse-logs/cse-server-debug.log
