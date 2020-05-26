#cloud-config
runcmd:
- apt-get update
- apt-get install -y git curl unzip
- apt-get install wget
- cd /tmp
- wget https://releases.hashicorp.com/consul/1.7.3/consul_1.7.3_linux_amd64.zip
- unzip -d /usr/local/bin consul*
- nohup consul agent -dev -http-addr=${userdata_consul_faas_mgmt_IP}:8500 & 
