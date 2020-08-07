resource "ciscoasa_access_in_rules" "access_partnerB" {
  interface = "management"
  
  rule {
    source              = "13.13.134.2/32"
    destination         = "127.0.0.1/32"
    destination_service = "tcp/0"
  }
  
}