/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  health_check = {
    check_interval_sec  = 1
    healthy_threshold   = 4
    timeout_sec         = 1
    unhealthy_threshold = 5
    port                = var.tcp_port
  }
}

module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 9.3"

    project_id   = var.project_id
    network_name = "nifi-vpc"
    routing_mode = "GLOBAL"

    subnets = [
        {
            subnet_name           = "nifi-subnet-01"
            subnet_ip             = "10.10.10.0/24"
            subnet_region         = var.region
        },
  
    ]
    ingress_rules = [
    {
      name        = "nifi-ingress-rule"
      description = "Allow NiFi web UI access+ssh+https"
      priority    = 1000
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["nifi-instance"]
      allow = [
        {
          protocol = "tcp"
          ports    = ["8080","8443","22"]
        }
      ]
    },
  ]
  egress_rules = [
        {
      name        = "nifi-egress-rule"
      description = "Allow outbound traffic from NiFi"
      priority    = 1000
      target_tags   = ["nifi-instance"]
      destination_ranges = ["0.0.0.0/0"]
      allow = [
        {
          protocol = "tcp"
        },
        {
          protocol = "udp"
        }
      ]
    }
  ]
}

module "instance_template_nifi" {
  source             = "terraform-google-modules/vm/google//modules/instance_template"
  version            = "~> 12.0"
  source_image       = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
  machine_type       = var.nifi_machine_type
  region             = var.region
  project_id         = var.project_id
  subnetwork         = var.subnetwork
  subnetwork_project = var.project_id
  service_account    = var.service_account_nifi

  additional_disks = [
    {
      auto_delete  = true
      boot         = false
      device_name  = "nifi-data-disk-1"
      disk_size_gb = 100
      disk_type    = "pd-ssd"
      labels       = { environment = "nifi" }
    },

    {
      auto_delete  = true
      boot         = false
      device_name  = "nifi-data-disk-2"
      disk_size_gb = 100
      disk_type    = "pd-ssd"
      labels       = { environment = "nifi" }
    }
  ]
}
module "instance_template_spark" {
  source             = "terraform-google-modules/vm/google//modules/instance_template"
  version            = "~> 12.0"
  source_image       = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
  machine_type       = var.spark_machine_type
  region             = var.region
  project_id         = var.project_id
  subnetwork         = var.subnetwork
  subnetwork_project = var.project_id
  service_account    = var.service_account_spark

  additional_disks = [
    {
      auto_delete  = true
      boot         = false
      device_name  = "spark-data-disk-1"
      disk_size_gb = 100
      disk_type    = "pd-ssd"
      labels       = { environment = "spark" }
    },
    {
      auto_delete  = true
      boot         = false
      device_name  = "spark-data-disk-2"
      disk_size_gb = 200
      disk_type    = "pd-balanced"
    }
  ]
}


module "compute_instance_nifi" {
  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "~> 12.0"

  region              = var.region
  zone                = var.zone
  subnetwork          = var.subnetwork
  subnetwork_project  = var.project_id
  num_instances       = var.num_instances
  hostname            = "nifi"
  add_hostname_suffix = true
  instance_template   = module.instance_template_nifi.self_link
  deletion_protection = false
  
  access_config = [{
    #nat_ip       = var.nat_ip
    network_tier = var.network_tier
  }, ]
}
module "compute_instance_spark" {
  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "~> 12.0"

  region              = var.region
  zone                = var.zone
  subnetwork          = var.subnetwork
  subnetwork_project  = var.project_id
  num_instances       = var.num_instances
  hostname            = "nifi"
  add_hostname_suffix = true
  instance_template   = module.instance_template_spark.self_link
  deletion_protection = false
  
  access_config = [{
    #nat_ip       = var.nat_ip
    network_tier = var.network_tier
  }, ]
}



module "load_balancer_custom_hc" {
  source  = "terraform-google-modules/lb/google"
  version = "~> 4.0"

  name         = "basic-load-balancer-custom-hc"
  region       = var.region
  service_port = var.tcp_port
  network      = module.vpc.network_name
  health_check = local.health_check

  target_service_accounts = [var.service_account_nifi.email]
}


# Managed Instance Group
resource "google_compute_instance_group_manager" "nifi_mig" {
  name                = "nifi-mig"
  zone                = var.zone
  base_instance_name  = "nifi-instance"
  target_size         = 3
  target_pools = [ google_compute_target_pool.nifi_pool ]
  version {
    instance_template = google_compute_instance_template.nifi_template.self_link
    name              = "v1" # Optional version name
  }
}
# Target Pool for Load Balancer (Optional)
resource "google_compute_target_pool" "nifi_pool" {
  name   = "nifi-pool"
  region = var.region
}
module "gce-lb-http" {
  source            = "GoogleCloudPlatform/lb-http/google"
  version           = "~> 9.0"

  project           = var.project_id
  name              = "group-http-lb"
  #target_tags       = [module.mig1.target_tags, module.mig2.target_tags]
  backends = {
    default = {
      port                            = var.service_port_http
      protocol                        = "HTTP"
      port_name                       = var.service_port_name_http
      timeout_sec                     = 10
      enable_cdn                      = false


      health_check = {
        request_path        = "/"
        port                = var.service_port_http
      }

      log_config = {
        enable = false
        sample_rate = 1.0
      }

      groups = [
        {
          # Each node pool instance group should be added to the backend.
          group                        = google_compute_instance_group_manager.nifi-mig.self_link
        },
      ]

      iap_config = {
        enable               = false
      }
    }
  }
}