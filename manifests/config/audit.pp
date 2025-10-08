class rke::config::audit (
  Boolean          $enabled = $rke::params::audit_enabled,
  Optional[String] $level   = $rke::params::audit_level,
) inherits rke::params {
  
  if $enabled {
    if defined(Package['rke2']) {
      $_require = Package['rke2']
    } else {
      $_require = Package_versionlock['rke2']
    }
    file{$rke::config::audit_file:
        ensure  => file,
        content => epp('rke/rke2-audit.yaml', {'auditlevel' => $level}),
        require => $_require,
        mode    => '0600',
    }
  }
}
