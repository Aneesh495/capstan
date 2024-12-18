# capstan_security::seccomp
# Deploys restrictive seccomp-bpf system call filters for edge runtime processes.
class capstan_security::seccomp {
  $seccomp_dir = '/etc/capstan/seccomp'

  file { $seccomp_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
  }

  seccomp_profile { 'capstand_strict':
    ensure           => present,
    default_action   => 'SCMP_ACT_ERRNO',
    profile_path     => "${seccomp_dir}/capstand_strict.json",
    allowed_syscalls => [
      'read', 'write', 'openat', 'close', 'stat', 'fstat', 'lstat', 'poll',
      'lseek', 'mmap', 'mprotect', 'munmap', 'brk', 'rt_sigaction',
      'rt_sigprocmask', 'ioctl', 'access', 'pipe2', 'select', 'sched_yield',
      'getpid', 'socket', 'connect', 'accept', 'sendto', 'recvfrom',
      'bind', 'listen', 'bpf', 'epoll_create1', 'epoll_ctl', 'epoll_wait',
      'clock_gettime', 'nanosleep', 'exit_group', 'futex'
    ],
    require          => File[$seccomp_dir],
  }
}
