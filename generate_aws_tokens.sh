#!/bin/bash

# Capture the output of the yawsso command and extract AWS credentials using command substitution
AWS_CREDENTIALS=$(yawsso login -e | yawsso decrypt)

echo "$AWS_CREDENTIALS"
# Extract AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_SESSION_TOKEN using grep and awk
AWS_ACCESS_KEY_ID=$(echo "$AWS_CREDENTIALS" | grep -oE 'AWS_ACCESS_KEY_ID=[A-Za-z0-9/=+.]+' | cut -d'=' -f2)
AWS_SECRET_ACCESS_KEY=$(echo "$AWS_CREDENTIALS" | grep -oE 'AWS_SECRET_ACCESS_KEY=[A-Za-z0-9/=+.]+' | cut -d'=' -f2)
AWS_SESSION_TOKEN=$(echo "$AWS_CREDENTIALS" | grep -oE 'AWS_SESSION_TOKEN=[A-Za-z0-9/=+.]+' | cut -d'=' -f2)

# Print the extracted credentials
echo "export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID"
echo "export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY"
echo "export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN"

export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN

# JSON content with dynamically populated AWS keys
json_content=$(cat <<-EOM
{
    "version": "0.2.0",
    "configurations": [
      {
        "name": "Launch Go Tests",
        "type": "go",
        "request": "launch",
        "mode": "test",
        "program": "\${file}",
        "env": {
          "AWS_ACCESS_KEY_ID": "$AWS_ACCESS_KEY_ID",
          "AWS_SECRET_ACCESS_KEY": "$AWS_SECRET_ACCESS_KEY",
          "AWS_SESSION_TOKEN": "$AWS_SESSION_TOKEN",
          "AWS_REGION": "eu-north-1"
        },
        "args": [
          "./..."
        ]
      }
    ]
}
EOM
)

# Save the JSON content to a file
echo "$json_content" > .vscode/launch.json

echo "launch.json file has been created with dynamically populated AWS credentials."
