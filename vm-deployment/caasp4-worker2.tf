# -------------------------------------------------------------
# File Name: caasp4-worker2.tf
# Deploy a new VM from a template.
#
# REQUIREMENTS #1: vsphere_tag_category and vsphere_tag must exist
#                  cd helpers/tags && terraform apply
# REQUIREMENTS #2: deploy_vsphere_folder and deploy_vsphere_sub_folder must exist
#                  cd helpers/folders && terraform apply
#
# Tue Dec 22 09:07:33 GMT 2020 - juliusn - initial script
# -------------------------------------------------------------

# -------------------------------------------------------------
# Create server - caasp4-worker2
# -------------------------------------------------------------

module "caasp4-worker2" {
    source          = "../modules/vsphere-deploy-linux-vm/"
    # -------------------------------------------------------------
    # INFRASTRUCTURE - VMware vSphere vCenter settings 
    # -------------------------------------------------------------
    vsphere_datacenter      = "WEST-DC"
    vsphere_cluster         = "WEST-Cluster"
    vsphere_datastore       = "vsanDatastore"
    vsphere_folder          = "CAASP-C1"
    vsphere_sub_folder      = "DEV-TEST"
    vsphere_resource_pool   = "CAASP-C1"

    # -------------------------------------------------------------
    # GUEST - VMware vSphere VM settings 
    # -------------------------------------------------------------
    guest_template          = "SLES-15.1-noX"
    guest_template_folder   = "Templates"
    guest_vm_name           = "caasp4-worker2"
    guest_vcpu              = "4"
    guest_memory            = "16384"
    guest_disk0_size        = "40"
    guest_network           = "lab-mgmt"
    guest_ipv4_address      = "192.168.120.115"
    guest_ipv4_netmask      = "24"
    guest_ipv4_gateway      = "192.168.120.1"
    guest_dns_servers       = "192.168.111.116"
    guest_dns_suffix        = "flexlab.local"
    guest_domain            = "flexlab.local"
       
    guest_category_name     = "CAASP"
    guest_tag_name          = "CAASP-C1"
}

output "caasp4-worker2-VM-ip" {
	value = module.caasp4-worker2.VM-ip
}
output "caasp4-worker2-VM-guest-ip" {
	value = module.caasp4-worker2.VM-guest-ip
}

