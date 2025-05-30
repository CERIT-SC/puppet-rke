class rke::cishardening (
  Boolean $enable      = $rke::params::cis_enable ,
  Array   $kubeconfigs = $rke::params::cis_kubeconfigs, 
) inherits rke::params {
  if $enable {
    $kubeconfigs.each |String $_config| {
      exec{$_config:
        command => "chmod 0600 \"$_config\"",
        onlyif  => "test -f \"$_config\" && stat -c %a \"$_config\" | grep -q '6[^0][^0]'",
      }
    }

    sysctl {'kernel.panic_on_oops':
        ensure => present,
        value  => 1,
    }

    sysctl {'vm.panic_on_oom':
      ensure => present,
      value  => 0,
    }

    sysctl {'kernel.panic':
      ensure => present,
      value  => 10,
    }

    sysctl {'vm.overcommit_memory':
      ensure => present,
      value  => 1,
    }

    sysctl {'fs.inotify.max_user_instances':
      ensure => present,
      value  => 65536,
    }
  }
}
