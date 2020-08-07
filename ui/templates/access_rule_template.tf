resource "ciscoasa_access_in_rules" "access_{{ partner_name }}" {
  interface = "{{ interface }}"
  {% for rule in rules %}
  rule {
    source              = "{{ rule.source_ip }}/32"
    destination         = "{{ rule.destination_ip }}/32"
    destination_service = "tcp/{{ rule.service_port }}"
  }
  {% endfor %}
}
