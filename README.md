# Cherry-Terraform-Haproxy-Example
<h1>Requirements:</h1>

- Make sure you have Terraform installed locally. Instructions can be found here: https://learn.hashicorp.com/terraform/getting-started/install.html

- Download CherryServers Terraform module from here: http://downloads.cherryservers.com/other/terraform/

<h1>Directions:</h1>

- Create an API Key for your CherryServers account at https://portal.cherryservers.com/#/settings/api-keys

- Export the key on working terminal session: export CHERRY_AUTH_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXUyJ9"

- Next, you will need an SSH key with which to access your servers and for terraform to use to provision your servers automatically.

- Use command: ssh-keygen -f ~/.ssh/cherry

- This will create ~/.ssh/cherry and ~/.ssh/cherry.pub

- Edit variables.tf and enter valid teamid

- Run template with command: terraform init

