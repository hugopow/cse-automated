# cse-automated
A bash script to install Container Service Extension 3.1.2

A example bash script to setup Container Service Extension 3.1.2 into VMware Photon OS 3.
You will need to remove my settings and replace them with your environment variables and passwords.
Just run on the Photon VM that will be running the CSE service.
This VM needs to be able to access the VCD portal over 443 and also the vCenter Servers that are registered in VCD as PVDCs.

Please refer to these two links to get familiar with Container Service Extension and preparing the Photon VM for CSE.
1. https://vmwire.com/2021/10/14/install-container-service-extension-3-1-1-with-vcd-10-3-1/
2. https://vmwire.com/2021/08/21/install-container-service-extension-as-a-service-on-photon-os-3/

USAGE INSTRUCTIONS

Get your Photon VM http://packages.vmware.com/photon/3.0/GA/ova/photon-hw13_uefi-3.0-26156e2.ova up and running with a hostname and IP address with outbound access to the Internet.

Get the script to the Photon VM by running the following command

curl https://raw.githubusercontent.com/hugopow/cse-automated/main/cse-install.sh --output cse-install.sh

# Make it executable
chmod +x cse-install.sh

# Edit the script and remove/add your details
#Run the script as root. The script will do the rest. Tested in environments with CA signed certificates.

sh cse-install.sh

# Demo Video
https://youtu.be/9Q2m0ncX8Mg
