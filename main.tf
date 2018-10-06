###############################################################################
## This main template file that includes minimal master worker configuration.
## For full setup, add proxy and management configuration at end of file
##
## Example code in install.sh:
##     ### main template - Master worker nodes only)
##     cp main.tf.tmpl main.tf
##     ## Add proxy and management node support
##     cat proxy-mgmt.tf.tmpl | tee -a main.tf
##
## @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################

provider "lxd"{
   generate_client_certificates = true
   accept_remote_certificate    = true

   ### Get info using command:  lxc remote list
   ### Local (usually default)
   ### Local declarion is not required
   ### LXD provider will fallback to local if no remotes defined
   lxd_remote {
     name     = "local"
     scheme   = "unix"
     address  = ""
     password = ""
   }

  # ### Images
  #  lxd_remote {
  #    name     = "images"
  #    scheme   = "https"
  #    address  = "images.linuxcontainers.org"
  #    password = ""
  #  }
  #
  # ### Ubuntu Remote (Releases)
  #  lxd_remote {
  #    name     = "ubuntu"
  #    scheme   = "https"
  #    address  = "cloud-images.ubuntu.com/releases"
  #    password = ""
  #  }
  #
  #  ### Ubuntu Remote (Daily)
  #   lxd_remote {
  #     name     = "ubuntu-daily"
  #     scheme   = "https"
  #     address  = "cloud-images.ubuntu.com/daily"
  #     password = ""
  #   }
}

module "network" {
  source = "./modules/network"
  environment="${var.environment}"
  lxd_network="${var.lxd_network}"
}

module "profile-master-worker" {
  source = "./modules/profile/master-worker"
  ### Outputs
  net_device_parent="${module.network.icp_ce_network_name_output}"
  ipv4_cidr_count="${module.network.ipv4_cidr_count_output}"
  ### Variables
  environment="${var.environment}"
  lxd_network="${var.lxd_network}"
  icp="${var.icp}"
  master_node="${var.master_node}"
  worker_node="${var.worker_node}"
  common_profile="${var.common_profile}"
}

module "container-master_worker" {
  source = "./modules/container/master-worker"
  ### Outputs
  icp_ce_profile_name= "${module.profile-master-worker.icp_ce_profile_name_output}"
  icp_ce_master_profile_name= "${module.profile-master-worker.icp_ce_master_profile_name_output}"
  icp_ce_worker_profile_name= "${module.profile-master-worker.icp_ce_worker_profile_name_output}"
  ### Variables
  environment="${var.environment}"
  cluster="${var.cluster}"
  lxd_image="${var.lxd_image}"
  icp="${var.icp}"
  master_node="${var.master_node}"
  worker_node="${var.worker_node}"
  icp_docker_image_archives="${var.icp_docker_image_archives}"
  common_profile="${var.common_profile}"  
}
