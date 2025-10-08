class rke::addon::criu ( 
   Boolean $enabled = $rke::params::criu_enabled,
) inherits rke::params  {
    if $enabled {
       package{'criu':
         ensure  => present,
       }
       file{'/etc/criu/runc.conf':
         ensure  => file,
         content => epp('rke/criu-runc.conf', {}),
       }
    }
}
