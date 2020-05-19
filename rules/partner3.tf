resource "ciscoasa_access_in_rules" "partner3" {
  interface = "management"
  rule {
    source              = "192.168.10.90/32"
    destination         = "192.168.15.0/25"
    destination_service = "tcp/443"
  }
}