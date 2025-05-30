class rke::addon::setenv (
    Boolean $enabled = $rke::params::setenv_enabled,
) inherits rke::params {
    if $enabled {
      contain rke

      file_line{'kubeconfig':
        ensure => present,
        path   => '/etc/environment',
        line   => 'KUBECONFIG=/etc/rancher/rke2/rke2.yaml',
        match  => 'KUBECONFIG'
      }

      file_line{'rkebinpath':
        ensure  => present,
        path    => '/etc/environment',
        line    => 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/var/lib/rancher/rke2/bin"',
        match   => 'PATH',
      }
    }
}
