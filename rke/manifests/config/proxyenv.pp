class rke::config::proxyenv (
  Boolean          $enabled = $rke::params::proxyenv_enabled,
  Optional[String] $proxy   = $rke::http_proxy,
  Optional[String] $noproxy = $rke::no_proxy,
) inherits rke::params {
  if $enabled {
     if $proxy {
       file{'/etc/default/rke2-server':
          ensure => file,
          content => epp('rke/rke2-env', { proxy => $proxy, noproxy => $noproxy }),
       }
       file{'/etc/default/rke2-agent':
          ensure => file,
          content => epp('rke/rke2-env', { proxy => $proxy, noproxy => $noproxy }),
       }
     } else {
       file{'/etc/default/rke2-server':
          ensure => absent,
       }
       file{'/etc/default/rke2-agent':
          ensure => absent,
       }
     }
  }
}
