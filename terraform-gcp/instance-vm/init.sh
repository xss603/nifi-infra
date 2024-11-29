echo "export GOOGLE_APPLICATION_CREDENTIALS="/appli/.secrets/${env}-vpodg1np-blue/gcp-sa-keys/gcp_vg1np_${env}_contributor_sa_key.json"" > /etc/profile.d/tf_envs
echo "export TF_CLI_ARGS_init="-backend-config=/appli/terraform-gcp/variables/platnifi-${env}-blue/platnifi-${env}-blue-backend.tfvars"" >> /etc/profile.d/tf_envs
echo "export TF_CLI_ARGS_plan="-var-file=/appli/terraform-gcp/variables/platnifi-${env}-blue/platnifi-${env}-blue.tfvars"" >> /etc/profile.d/tf_envs
echo "export TF_CLI_ARGS_apply="-var-file=/appli/terraform-gcp/variables/platnifi-${env}-blue/platnifi-${env}-blue.tfvars"" >> /etc/profile.d/tf_envs
echo "export TF_CLI_ARGS_refresh="-var-file=/appli/terraform-gcp/variables/platnifi-${env}-blue/platnifi-${env}-blue.tfvars"" >> /etc/profile.d/tf_envs
echo "export TF_CLI_ARGS_destroy="-var-file=/appli/terraform-gcp/variables/platnifi-${env}-blue/platnifi-${env}-blue.tfvars"" >> /etc/profile.d/tf_envs