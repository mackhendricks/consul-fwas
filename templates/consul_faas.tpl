#cloud-config
runcmd:
- apt-get update
- apt-get install -y git curl unzip python3-pip
- apt-get install wget
- cd /tmp
- wget https://releases.hashicorp.com/consul/1.7.3/consul_1.7.3_linux_amd64.zip
- unzip -d /usr/local/bin consul*
- wget https://releases.hashicorp.com/terraform/0.12.29/terraform_0.12.29_linux_amd64.zip
- unzip -d /usr/local/bin terra*
- nohup consul agent -dev -client=${userdata_consul_faas_mgmt_IP} &
- cd /opt
- git clone https://github.com/mackhendricks/consul-fwas faas 
- cd faas/ui
- CONSUL_HOST=${userdata_consul_faas_mgmt_IP} APP_HOST=${userdata_consul_faas_mgmt_IP} ASA_HOST=${userdata_asa_host_IP} nohup ./deploy.sh &

