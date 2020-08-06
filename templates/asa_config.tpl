! ASA Version 9.12(2)
!
hostname ${userdata_owner}
enable password cisco

interface management0/0
management-only
nameif management
security-level 100
ip address dhcp setroute
no shut
!
interface ethernet0/0
nameif outside
security-level 0
ip address dhcp setroute
no shut
!
interface ethernet0/1
nameif inside
security-level 100
ip address dhcp setroute
no shut
!
same-security-traffic permit inter-interface
same-security-traffic permit intra-interface
!
crypto key generate rsa modulus 2048
ssh 0 0 management
ssh timeout 30
username api password cisco privilege 15
username admin nopassword privilege 15
username admin attributes
service-type admin
!
aaa authentication http console LOCAL
http server enable
user-identity default-domain LOCAL
http 0.0.0.0 0.0.0.0 management
rest-api image boot:/asa-restapi-132346-lfbff-k8.SPA
rest-api agent
