
resource "ciscoasa_access_in_rules" "partner2" {
  interface = "management"
  rule {
    source              = "192.168.10.89/32"
    destination         = "192.168.15.0/25"
    destination_service = "tcp/443"
  }
}