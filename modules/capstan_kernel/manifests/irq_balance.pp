# capstan_kernel::irq_balance
# Configures IRQ affinity balancing and bans interrupts from isolated real-time cores.
class capstan_kernel::irq_balance {
  $banned_cpus = $capstan_kernel::isolated_cores
  $irqbalance_conf = '/etc/default/irqbalance'

  # Generate hexadecimal or comma-separated CPU mask if isolated cores exist
  $banned_mask = if empty($banned_cpus) {
    '0'
  } else {
    $banned_cpus.join(',')
  }

  file { $irqbalance_conf:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "# Capstan irqbalance configuration\nENABLED=\"1\"\nIRQBALANCE_BANNED_CPUS=\"${banned_mask}\"\n",
  }
}
