class rke::config::audit (
  Boolean          $enabled = $rke::params::audit_enabled,
  Optional[String] $level   = $rke::params::audit_level,
) inherits rke::params {
  
  if $enabled {
    file{$rke::config::audit_file:
        ensure  => file,
        content => epp('rke/rke2-audit.yaml', {'auditlevel' => $level}),
        require => Package_versionlock['rke2'],
        mode    => '0600',
    }
  }
}
