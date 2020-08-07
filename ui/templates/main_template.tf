provider "ciscoasa" {
  api_url       = "https://{{ asa_host }}"
  username      = "api"
  password      = "cisco"
  ssl_no_verify = true
}
