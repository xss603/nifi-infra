#!/bin/sh

echo "export GOOGLE_APPLICATION_CREDENTIALS="/appli/.secrets/sa_key.json"" > /etc/profile.d/tf_envs
#echo "export TF_CLI_ARGS_init="-backend-config=-backend.tfvars"" >> /etc/profile.d/tf_envs
echo "export TF_CLI_ARGS_plan="-var-file=/appli/terraform-gcp/instance-vm/variables/prd/nifi-prd.tfvars"" >> /etc/profile.d/tf_envs
echo "export TF_CLI_ARGS_apply="-var-file=/appli/terraform-gcp/instance-vm/variables/prd/nifi-prd.tfvars"" >> /etc/profile.d/tf_envs
echo "export TF_CLI_ARGS_refresh="-var-file=/appli/terraform-gcp/instance-vm/variables/prd/nifi-prd.tfvars"" >> /etc/profile.d/tf_envs
echo "export TF_CLI_ARGS_destroy="-var-file=/appli/terraform-gcp/instance-vm/variables/prd/nifi-prd.tfvars"" >> /etc/profile.d/tf_envs

source /etc/profile.d/tf_envs

# docker run -ti --name nifi-infra-gcp -v /utils/nifi-gcp:/appli alpine
# gcloud compute addresses create nifi-static-ip --region=europe-west1

# terraform init 
# terraform plan
# terraform apply
# terraform destroy

