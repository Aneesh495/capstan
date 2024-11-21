# capstan_network::traffic_shaping
# Configures tc token bucket filter rate-limiting for deterministic latency.
class capstan_network::traffic_shaping {
  $interface  = $capstan_network::interface_name
  $rate_mbps  = $capstan_network::params::rate_limit_mbps
  $burst_kb   = 256
  $latency_ms = 10

  exec { "capstan_tc_shape_${interface}":
    command => "tc qdisc replace dev ${interface} root tbf rate ${rate_mbps}mbit burst ${burst_kb}k latency ${latency_ms}ms",
    path    => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'],
    onlyif  => "ip link show ${interface} && which tc",
  }
}
