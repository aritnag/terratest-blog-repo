#!/bin/bash

## Configure cluster name using the template variable ${ecs_cluster_name}

echo ECS_CLUSTER='${ecs_cluster_name}' >> /etc/ecs/ecs.config

# # Install AWS Cloud Tools
# sudo apt-get update -y
# sudo apt-get install -y python3-pip python3-setuptools unzip
# wget https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-py3-latest.tar.gz
# sudo python3 -m easy_install aws-cfn-bootstrap-py3-latest.tar.gz
# tar xf aws-cfn-bootstrap-py3-latest.tar.gz aws-cfn-bootstrap-2.0/init/ubuntu/cfn-hup -O | sudo tee /etc/init.d/cfn-hup
# sudo chmod +x /etc/init.d/cfn-hup
# sudo mkdir -p /opt/aws/bin
# ln -s /usr/local/bin/cfn-* /opt/aws/bin/

# # Install CodeDeploy Agent
# sudo apt-get install -y ruby2.7
# wget https://aws-codedeploy-eu-north-1.s3.eu-north-1.amazonaws.com/latest/install
# chmod +x ./install
# sudo ./install auto > /tmp/logfile

# # Install CloudWatch Agent
# wget https://s3.eu-north-1.amazonaws.com/amazoncloudwatch-agent-eu-north-1/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
# sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

# # Install XRay Daemon
# wget https://s3.eu-north-1.amazonaws.com/aws-xray-assets.eu-north-1/xray-daemon/aws-xray-daemon-3.x.deb
# sudo dpkg -i -E ./aws-xray-daemon-3.x.deb
# sudo sed -i  "s/^\(ExecStart=\/usr\/bin\/xray\).*/\1 -c \/opt\/aws\/xray.yml/g" /lib/systemd/system/xray.service
# sudo systemctl daemon-reload

# # Install awscli
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# sudo ./aws/install

# # Install docker
# sudo apt-get install \
#      ca-certificates \
#      curl \
#      gnupg \
#      lsb-release

# sudo mkdir -p /etc/apt/keyrings
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# echo \
#   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
#   $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# sudo apt-get update
# sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

