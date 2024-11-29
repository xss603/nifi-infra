# .tfvars file for Terraform variable values

# GCP project and region settings
project_id  = "my-gcp-project-id"             # Replace with your GCP project ID
region      = "europe-west1"                   # Specify the region (default provided)
zone        = "europe-west1-b"                 # Specify the zone (optional)

# Networking
subnetwork  = "projects/my-project/regions/us-central1/subnetworks/nifi-subnet-01" # Subnetwork self-link
nat_ip      = "X.X.X.X"                  # Public IP address (null if not used)
network_tier = "PREMIUM"                      # Network tier (PREMIUM or STANDARD)

# Compute instance settings
num_instances = 2                             # Number of instances to create

# Service account
service_account = {
  email  = "nifi-vms@my-project.iam.gserviceaccount.com" # Service account email
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",              # Add required scopes
    "https://www.googleapis.com/auth/compute"
  ]
}






