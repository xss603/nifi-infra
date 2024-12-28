# .tfvars file for Terraform variable values

# GCP project and region settings
project_id  = "groovy-footing-326602"             # Replace with your GCP project ID
region      = "europe-west1"                   # Specify the region (default provided)
zone        = "europe-west1-b"                 # Specify the zone (optional)

# Networking
subnetwork  = "projects/groovy-footing-326602/regions/europe-west1/subnetworks/nifi-subnet-01" # Subnetwork self-link
nat_ip      = "X.X.X.X"                  # Public IP address (null if not used)
network_tier = "PREMIUM"                      # Network tier (PREMIUM or STANDARD)

# Compute instance settings
num_instances = 3                             # Number of instances to create
nifi_machine_type="e2-standard"
spark_machine_type="e2-standard"
# Service account
service_account_nifi = {
  email  = "nifi-vms@groovy-footing-326602.iam.gserviceaccount.com" # Service account email
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",              # Add required scopes
    "https://www.googleapis.com/auth/compute"
  ]
}

service_account_spark = {
  email  = "spark-vms@groovy-footing-326602.iam.gserviceaccount.com" # Service account email
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",              # Add required scopes
    "https://www.googleapis.com/auth/compute"
  ]
}



tcp_port=1234


