class rke::cishardening (
  Boolean         $enable          = $rke::params::cis_enable ,
  Array           $kubeconfigs     = $rke::params::cis_kubeconfigs,
  Optional[Array] $controlplaneips = undef,    
) inherits rke::params {
  if $enable {
    $kubeconfigs.each |String $_config| {
      exec{$_config:
        command => "/bin/chmod 0600 \"$_config\"",
        onlyif  => "/bin/test -f \"$_config\" && stat -c %a \"$_config\" | grep -q '6[^0][^0]'",
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

    if $controlplaneips != undef and $rke::cni =~ /calico/ and $rke::node_type =~ /controlplane/ {
        file{'/var/lib/rancher/rke2/server/manifests/calico-rancher-webhook-filter.yaml':
           ensure  => file,
           content => epp('rke/calico-rancher-webhook-filter.yaml', {ips => $controlplaneips}),
        }
    } 

    if $rke::cni =~ /cilium/ and $rke::node_type =~ /controlplane/ {
        file{'/var/lib/rancher/rke2/server/manifests/cilium-rancher-webhook-filter.yaml':
           ensure  => file,
           content => epp('rke/cilium-rancher-webhook-filter.yaml', {}),
        }
    } 

  }
}
