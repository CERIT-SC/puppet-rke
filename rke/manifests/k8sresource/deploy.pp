define rke::k8sresource::deploy (
  String $filename,
  Optional[String] $content   = undef,
  Optional[String] $source    = undef,
  Optional[String] $namespace = undef,
){

  if ($content == undef and $source == undef) or ($content != undef and $source != undef) {
    fail("Exactly one argument (content or source) must be enetered")
  }

  if ! defined(File[$filename]) {
    if $content != undef {
      file { $filename:
        ensure  => 'file',
        content => $content,
        mode    => '0600',
      }
    } else {
      file { $filename:
        ensure => 'file',
        source => $source,
        mode   => '0600',
      }
    }
  }

  if $namespace != undef {
    $_namespace = "-n ${namespace}"
  } else {
    $_namespace = ""
  }  

  exec { $title:
    require     => File[$filename],
    environment => ['KUBECONFIG=/etc/rancher/rke2/rke2.yaml'],
    command     => "/var/lib/rancher/rke2/bin/kubectl apply -f ${filename} ${_namespace}",
    unless      => "/var/lib/rancher/rke2/bin/kubectl diff -f ${filename} ${_namespace}",
  }
}  
