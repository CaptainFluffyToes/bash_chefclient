#!/bin/bash

# Do some chef pre-work
/bin/mkdir -p /etc/chef
/bin/mkdir -p /var/lib/chef
/bin/mkdir -p /var/log/chef

# Setup hosts file correctly
cat > "/etc/hosts" << EOF
10.0.0.5    compliance-server compliance-server.automate.com
10.0.0.6    chef-server chef-server.automate.com
10.0.0.7    automate-server automate-server.automate.com
EOF

cd /etc/chef/

# Install chef
curl -L https://omnitruck.chef.io/install.sh | bash || error_exit 'could not install chef'

# Create first-boot.json
cat > "/etc/chef/first-boot.json" << EOF
{
   "run_list" :[
   "role[base]"
   ]
}
EOF

NODE_NAME=node-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)

# Create client.rb
/bin/echo 'log_location     STDOUT' >> /etc/chef/client.rb
/bin/echo -e "chef_server_url  \"https://aut-chef-server/organizations/my-org\"" >> /etc/chef/client.rb
/bin/echo -e "validation_client_name \"my-org-validator\"" >> /etc/chef/client.rb
/bin/echo -e "validation_key \"/etc/chef/my_org_validator.pem\"" >> /etc/chef/client.rb
/bin/echo -e "node_name  \"${NODE_NAME}\"" >> /etc/chef/client.rb

sudo chef-client -j /etc/chef/first-boot.json
