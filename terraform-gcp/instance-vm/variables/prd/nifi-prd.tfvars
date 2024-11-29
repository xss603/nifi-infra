# .tfvars file for Terraform variable values

# GCP project and region settings
project_id  = "my-gcp-project-id"             # Replace with your GCP project ID
region      = "us-central1"                   # Specify the region (default provided)
zone        = "us-central1-a"                 # Specify the zone (optional)

# Networking
subnetwork  = "projects/my-project/regions/us-central1/subnetworks/my-subnetwork" # Subnetwork self-link
nat_ip      = "34.123.45.67"                  # Public IP address (null if not used)
network_tier = "PREMIUM"                      # Network tier (PREMIUM or STANDARD)

# Compute instance settings
num_instances = 2                             # Number of instances to create

# Service account
service_account = {
  email  = "my-service-account@my-project.iam.gserviceaccount.com" # Service account email
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",              # Add required scopes
    "https://www.googleapis.com/auth/compute"
  ]
}
