class rke::config::boot (
  Boolean $enabled       = $rke::params::prebootenabled,
  Optional[String] $file = $rke::config::kubelet_config_file,
) inherits rke::params {

  if $enabled {
 
    if rke::config::grace_period and $rke::config::grace_period_critical {

      $_dir = dirname($file)

      exec{"ensure ${_dir}":
        command => "mkdir -p ${_dir}",
        unless  => "test -d ${_dir}",
      }

      file{$file:
        ensure    => file,
        mode      => '0600',
        show_diff => false,
        content   => epp('rke/kubelet.config', { 'graceperiod'         => $rke::config::grace_period,
                                                 'graceperiodcritical' => $rke::config::grace_period_critical}),
        require   => Exec["ensure ${_dir}"],
      }
    }

    if $rke::config::k8s_preboot {
      file{'/usr/lib/systemd/system/k8s-preboot.service':
        ensure  => file,
        content => epp('rke/k8s-preboot.service', {}),
      } ~> exec{'reload-k8spreboot':
        command     => 'systemctl daemon-reload',
        refreshonly => true,
      }
      service{'k8s-preboot':
        ensure => 'running',
        enable => true,
      }
    }
  }
}
