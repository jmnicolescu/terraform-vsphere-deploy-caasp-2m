#!/bin/sh
#--------------------------------------------------------------------------------------
# CaaSP 4.2.5 / SUSE Linux Enterprise Server 15 SP1
#
#  - Configure firewalld for kubernetes
#
# Tue Feb 23 07:26:42 GMT 2021 - juliusn - initial script
#--------------------------------------------------------------------------------------

HOSTNAME=`hostname`
echo -e "\n[ ${HOSTNAME} ] --> Running script $0 \n"

echo "Sleeping 120...."
sleep 120


# Allow Kubernetes traffic - Master Server
firewall-cmd --zone=public --add-port={2379-2380,4240,5473,6443,10250-10256,30000-32767}/tcp --permanent
firewall-cmd --zone=public --add-port={4789,8285,8472}/udp --permanent

# Allow Kubernetes traffic - Worker Nodes
firewall-cmd --zone=public --add-port={4240,5473,10250-10256,30000-32767}/tcp --permanent
firewall-cmd --zone=public --add-port={4789,8285,8472}/udp --permanent

# Allow traffic for the flannel default port 8285
firewall-cmd --zone=public --permanent --add-port=8285/tcp
firewall-cmd --zone=public --permanent --add-port=8285/udp

# Allow traffic for the Weave Net default port 6783,6784 
firewall-cmd --zone=public --permanent --add-port=6783-6784/tcp
firewall-cmd --zone=public --permanent --add-port=6783-6784/udp

# Allow traffic for the Cilium default port 4240, 8472
# 4240 TCP Internal Cilium healthcheck
# 8472 UDP Internal Cilium VXLAN
firewall-cmd --zone=public --permanent --add-port=4240/tcp
firewall-cmd --zone=public --permanent --add-port=8472/udp

# Expose NodePorts on control plane IP
firewall-cmd --zone=public --permanent --add-port=30000-32767/tcp

# Allow traffic for different ports and demo apps
firewall-cmd --zone=public --permanent --add-port={22,80,443,8000-8005,8080-8085}/tcp
firewall-cmd --zone=public --permanent --add-port={53,514,9153,8181}/tcp
firewall-cmd --zone=public --permanent --add-port={53,514}/udp
firewall-cmd --reload
firewall-cmd --list-services
firewall-cmd --list-ports

cat << EOF >> /etc/hosts
#
# caasp4-cluster host configuration
#
192.168.120.110  caasp4-admin.flexlab.local      caasp4-admin
192.168.120.111  caasp4-master1.flexlab.local    caasp4-master1
192.168.120.112  caasp4-master2.flexlab.local    caasp4-master2
192.168.120.113  caasp4-master3.flexlab.local    caasp4-master3
192.168.120.114  caasp4-worker1.flexlab.local    caasp4-worker1
192.168.120.115  caasp4-worker2.flexlab.local    caasp4-worker2
192.168.120.115  caasp4-worker3.flexlab.local    caasp4-worker3
192.168.120.117  caasp4-worker4.flexlab.local    caasp4-worker4
192.168.120.118  caasp4-worker5.flexlab.local    caasp4-worker5
192.168.120.119  caasp4-worker6.flexlab.local    caasp4-worker6
192.168.120.120  caasp4-cluster1.flexlab.local   caasp4-cluster1
192.168.120.121  caasp4-vip1.flexlab.local       caasp4-vip1
EOF

# Copy the scripts directory to caaspadm home directory
chmod 755 /root/scripts/*.sh
cp -r /root/scripts /home/caaspadm
chown -R caaspadm:users /home/caaspadm/scripts

exit 0
