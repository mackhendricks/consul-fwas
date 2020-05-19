resource "ciscoasa_access_in_rules" "partner1" {
  interface = "management"
  rule {
    source              = "192.168.10.5/32"
    destination         = "192.168.15.0/25"
    destination_service = "tcp/443"
  }

  rule {
    source              = "192.168.10.0/23"
    destination         = "192.168.12.0/23"
    destination_service = "icmp/0"
  }
}
