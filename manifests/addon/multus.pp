class rke::addon::multus ( 
   Boolean $enabled     = $rke::params::multus_enabled,
   Boolean $whereabouts = $rke::params::multus_whereabouts,
) inherits rke::params  {
    if $enabled {
       file{"/var/lib/rancher/rke2/server/manifests/rke2-multus-config.yaml":
          ensure  => file,
          content => epp('rke/rke2-multus-config.yaml', {whereabouts => $whereabouts}),
          mode    => '0600',
       }
    }
}
