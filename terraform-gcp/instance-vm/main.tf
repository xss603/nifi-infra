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

module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 12.0"
  source_image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
  machine_type= "n1-standard-1"
  region             = var.region
  project_id         = var.project_id
  subnetwork         = "nifi-subnet-01"
  subnetwork_project = var.project_id
  service_account    = var.service_account
}

module "compute_instance" {
  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "~> 12.0"

  region              = var.region
  zone                = var.zone
  subnetwork          = var.subnetwork
  subnetwork_project  = var.project_id
  num_instances       = var.num_instances
  hostname            = "instance-simple"
  instance_template   = module.instance_template.self_link
  deletion_protection = false

  access_config = [{
    nat_ip       = var.nat_ip
    network_tier = var.network_tier
  }, ]
}
