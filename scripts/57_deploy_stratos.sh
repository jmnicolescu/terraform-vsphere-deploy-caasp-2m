#!/bin/sh
#--------------------------------------------------------------------------------------
# CaaSP 4.2.5 / SUSE Linux Enterprise Server 15 SP1
#
#  - Deploy and configure stratos - Installation For Subdomains
#
#  - Run the script only as caaspadm user [ EUID=1000 ]
#
# Tue Feb 23 07:26:42 GMT 2021 - juliusn - initial script
# Sun Mar  7 05:28:01 GMT 2021 - juliusn - added check for caaspadm user
#--------------------------------------------------------------------------------------
# Deployment Instructions - SUSE CaaS Platform 4.5.2
# https://documentation.suse.com/suse-caasp/4.5/html/caasp-deployment/_deployment_instructions.html

# Administration Guide - SUSE CaaS Platform 4.5.2
# https://documentation.suse.com/suse-caasp/4.5/html/caasp-admin/index.html

LB_FQDN=caasp4-cluster1.flexlab.local
LB_IP=192.168.120.120

HOSTNAME=`hostname`
echo -e "\n[ ${HOSTNAME} ] --> Running script $0 \n"

# Run the script only as caaspadm user [ EUID=1000 ]
if [ "$EUID" != 1000 ]; then 
		echo -e "\n[ ${HOSTNAME} ] Run the script only as caaspadm user [ EUID=1000 ]\n"
		exit 1
fi 

#--------------------------------------------------------------------------------------
# Deploy and configure stratos - c1-stratos.flexlab.local 
#--------------------------------------------------------------------------------------

echo -e "\n[ ${HOSTNAME} ] Installing Stratos. \n"
kubectl create namespace stratos

# Obtain the default values.yaml file of the helm chart
# helm3 inspect values suse/console > stratos-values.yaml

# Create TLS secret for c1-stratos.flexlab.local
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout deploy-stratos/stratos-tls.key -out deploy-stratos/stratos-tls.crt -subj "/CN=c1-stratos.flexlab.local/O=c1-stratos"
kubectl create secret tls stratos-tls --key deploy-stratos/stratos-tls.key --cert deploy-stratos/stratos-tls.crt -n stratos

export stratos_key=`base64 -w0 deploy-stratos/stratos-tls.key`
export stratos_crt=`base64 -w0 deploy-stratos/stratos-tls.crt`

# helm3 repo add suse https://kubernetes-charts.suse.com
helm3 install stratos-console suse/console --namespace stratos --values deploy-stratos/55_stratos_values_small.yaml --set console.service.ingress.tls.crt="$stratos_crt" --set console.service.ingress.tls.key="$stratos_key"


echo -e "\n[ ${HOSTNAME} ] Creating /etc/host entry for c1-stratos.flexlab.local [ ${LB_IP} ]\n"
echo ${LB_IP} > /tmp/EXTERNAL_IP
cp /home/caaspadm/.kube/config /tmp/kubeconfig

sudo bash -c 'cat << EOF >> /etc/hosts
###
### Stratos - Installation For Subdomains
###
`cat /tmp/EXTERNAL_IP` c1-stratos.flexlab.local c1-stratos
EOF'

echo -e "\n[ ${HOSTNAME} ] ->> Stratos Console [ https://c1-stratos.flexlab.local ]"
echo -e "\n[ ${HOSTNAME} ] ->> Default login info admin/tux"
echo -e "\n[ ${HOSTNAME} ] ->> Looking for the Endpoint Address\n"
kubectl cluster-info | grep 'Kubernetes master'
echo -e "\n[ ${HOSTNAME} ] ->> Add Endpoint ->> SUSE CaaS Platform --> Specify kubeconfig file: /tmp/kubeconfig"
echo -e "\n[ ${HOSTNAME} ] ->> Install Service Account, Install Kubernetes Dashboard"

echo -e "\n[ ${HOSTNAME} ] ... sleeping 180 ... waiting for stratos containers deployment ... \n"
sleep 180

# -- to remove stratos --
# helm3 ls --all  --namespace stratos
# helm3 delete stratos-console --namespace stratos
# kubectl delete namespace stratos

exit 0

