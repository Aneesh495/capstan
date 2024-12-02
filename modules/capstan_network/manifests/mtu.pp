# capstan_network::mtu
# Enforces TCP Maximum Segment Size (MSS) clamping to prevent path MTU blackholes.
class capstan_network::mtu {
  $interface = $capstan_network::interface_name

  exec { "capstan_clamp_mss_${interface}":
    command => "iptables -t mangle -A FORWARD -o ${interface} -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu",
    path    => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'],
    unless  => "iptables -t mangle -C FORWARD -o ${interface} -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null",
    onlyif  => 'which iptables',
  }
}
