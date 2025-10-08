class rke::addon::containerd (
    Boolean $enabled = $rke::params::containerd_enabled,
) inherits rke::params {
    if $enabled {
      contain rke

      if $facts['nvidiatoolkit'] == 'present' {

          $_cerit = $rke::registries['cerit.io']
          $_eicr =  $rke::registries['eicr.vm.cesnet.cz']

          exec{'ensure /var/lib/rancher/rke2/agent/etc/containerd':
            command => '/bin/mkdir -p /var/lib/rancher/rke2/agent/etc/containerd',
            unless  => '/bin/test -d /var/lib/rancher/rke2/agent/etc/containerd',
          }

          file{'/var/lib/rancher/rke2/agent/etc/containerd/config-v3.toml.tmpl':
             ensure    => file,
             owner     => 'root',
             mode      => '0600',
             show_diff => false,
             content   => epp('rke/config.toml.tmpl', { 'ceritpassword' => $_cerit['password'], 'eicrpassword' => $_eicr['password'] }),
             require   => Exec['ensure /var/lib/rancher/rke2/agent/etc/containerd'],
          }
      } else {
          file{'/var/lib/rancher/rke2/agent/etc/containerd/config-v3.toml.tmpl':
              ensure    => absent,
          }
      }
    }
}
