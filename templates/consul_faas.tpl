#cloud-config
runcmd:
- apt-get update
- apt-get install -y git curl unzip python3-pip
- apt-get install wget
- cd /tmp
- wget https://releases.hashicorp.com/consul/1.7.3/consul_1.7.3_linux_amd64.zip
- unzip -d /usr/local/bin consul*
- nohup consul agent -dev -client=${userdata_consul_faas_mgmt_IP} &
- cd /opt
- git clone https://github.com/mackhendricks/terraform-aws-asav faas 
- cd faas/ui
- CONSUL_HOST=${userdata_consul_faas_mgmt_IP} APP_HOST=${userdata_consul_faas_mgmt_IP} nohup ./deploy.sh &
