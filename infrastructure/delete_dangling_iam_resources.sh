#!/bin/bash

account_id="127745533311"
env_name="demodev"
# List of policy ARNs to delete



policy_arns=(
  "arn:aws:iam::$account_id:policy/blogtemo-$env_name-AppConfigAccessPolicy"
  "arn:aws:iam::$account_id:policy/blogtemo-$env_name-CustomECSInstancePolicy"
    "arn:aws:iam::$account_id:policy/blogtemo-$env_name-ECRRolePolicy"
  "arn:aws:iam::$account_id:policy/blogtemo-$env_name-ECRTaskExecutionPolicy"
  "arn:aws:iam::$account_id:policy/blogtemo-$env_name-module-blogdemo-lamda-role"
  "arn:aws:iam::$account_id:policy/blogtemo-$env_name-CustomECSInstancePolicy"
  "arn:aws:iam::$account_id:policy/blogtemo-$env_name-module-blogdemo-lamda-role-logs"

  # Add more policy ARNs as needed
)

# Loop through each policy ARN and delete it
for arn in "${policy_arns[@]}"; do
  aws iam delete-policy --policy-arn "$arn"
done
