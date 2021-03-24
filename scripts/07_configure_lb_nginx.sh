#!/bin/sh
#--------------------------------------------------------------------------------------
# CaaSP 4.2.5 / SUSE Linux Enterprise Server 15 SP1
#
#  - Install NGINX & Configure Load Balancer
#
# Tue Feb 23 07:26:42 GMT 2021 - juliusn - initial script
# Sun Mar  7 05:28:01 GMT 2021 - juliusn 
#--------------------------------------------------------------------------------------

# Setting up a load balancer is mandatory in any production environment.
# SUSE CaaS Platform requires a load balancer to distribute workload between the deployed master nodes of the cluster.
# The load balancer needs access to port 6443 on the apiserver (all master nodes) in the cluster. 
# It also needs access to Gangway port 32001 and Dex port 32000 on all master and worker nodes in the cluster for RBAC authentication.

nginx_conf=/root/scripts/deploy-lb-nginx/nginx.conf

HOSTNAME=`hostname`
echo -e "\n[ ${HOSTNAME} ] --> Running script $0 \n"

if [ ${HOSTNAME} != "caasp4-admin" ]; then
    echo -e "\n[ ${HOSTNAME} ] --> Will NOT run script $0 \n"
    exit 0
else
    echo -e "\n[ ${HOSTNAME} ] --> Running script $0 \n"
fi

if [ ! -f $nginx_conf ]; then
   echo -e "\n[ ${HOSTNAME} ] --> $nginx_conf file doesn't exist. \n"
   exit 1
fi

echo -e "\n[ ${HOSTNAME} ] Add virtual Interfaces \n"

cat << EOF >> /etc/sysconfig/network/ifcfg-eth0
### caasp4-cluster1.flexlab.local  
IPADDR_0=192.168.120.120
NETMASK_0=255.255.255.0
LABEL_0=0
### caasp4-vip1.flexlab.local
IPADDR_1=192.168.120.121
NETMASK_1=255.255.255.0
LABEL_1=1
EOF
systemctl restart network


echo -e "\n[ ${HOSTNAME} ] Install NGINX & Configure Load Balancer \n"

zypper -n install nginx
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.save
cp $nginx_conf /etc/nginx/nginx.conf

systemctl enable nginx
systemctl start nginx

echo -e "\n[ ${HOSTNAME} ] Looking for nginx processes ... \n"
ps -auxw | grep nginx
echo -e "\n[ ${HOSTNAME} ] Looking for local opened ports ... \n"
nmap ${HOSTNAME}

exit 0

