resource "ciscoasa_access_in_rules" "access_partnerA" {
  interface = "management"
  
  rule {
    source              = "124.234.24.2/32"
    destination         = "127.0.0.1/32"
    destination_service = "tcp/443"
  }
  
}
