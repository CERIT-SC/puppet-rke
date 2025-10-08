class rke::config::pss (
  Boolean          $enabled      = $rke::params::pss_enabled,
  Optional[Array]  $namespaces   = $rke::psa_privileged_ns,
) inherits rke::params {
  
  if $enabled {
    if defined(Package['rke2']) {
      $_require = Package['rke2']
    } else {
      $_require = Package_versionlock['rke2']
    }
    file{$rke::config::pss_file:
       ensure  => file,
       content => epp('rke/rke2-pss-cerit.yaml', {'psaprivilegedns' => $namespaces}),
       require => $_require,
       mode    => '0600',
    }
  }
}
