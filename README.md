# Cherry-Terraform-Haproxy-Example
Cherry-Terraform-Haproxy-Example
Requirements:
Make sure you have Terraform installed locally. Instructions can be found here: https://learn.hashicorp.com/terraform/getting-started/install.html
Download CherryServers Terraform module from here:

Directions:
Create an API Key for your CherryServers account at https://portal.cherryservers.com/#/settings/api-keys
Export the key on working terminal session: export CHERRY_AUTH_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXUyJ9"
Next, you will need an SSH key with which to access your servers and for terraform to use to provision your servers automatically.
ssh-keygen -f ~/.ssh/cherry
This will create ~/.ssh/cherry and ~/.ssh/cherry.pub

