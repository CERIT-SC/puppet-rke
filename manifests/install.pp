class rke::install (
    String  $version        = $rke::params::rke2_version,
    Boolean $etcduser       = $rke::params::etcduser,
    Boolean $disableubuntu  = $rke::params::disableubuntu,
    Array   $addpackages    = $rke::params::addpackages,
    Boolean $useversionlock = $rke::params::use_version_lock,
    String  $kubeletdir     = $rke::params::kubelet_dir,
) inherits rke::params 
{

   if $useversionlock {
     package_versionlock{'rke2':
       ensure => $version,
       locked => true,
     }
   } else {
     package{'rke2':
       ensure => $version,
     }
   }

   file{'/var/lib/rancher':
     ensure => directory,
   }

   file{'/var/lib/rancher/rke2':
     ensure => directory,
   }

   file{'/var/lib/rancher/rke2/server':
     ensure => directory,
   }
 
   file{'/var/lib/rancher/rke2/server/values':
     ensure => directory,
     mode   => '0700',
   }

   if $kubeletdir != '/var/lib/kubelet' {
      file{$kubeletdir:
        ensure => directory,
      }
      file{'/var/lib/kubelet':
        ensure => link,
        target => $kubeletdir,
      }
   }

   if $etcduser {
     user{'etcd':
       ensure  => present,
       comment => 'etcd user',
       shell   => '/sbin/nologin',
       system  => true,
     }
   }

   if $disableubuntu {
     user{'ubuntu':
       shell    => '/sbin/nologin',
     }
   }

   if $addpackages != [] {
     package{$addpackages:
       ensure => present,
     }
   } 

   if $rke::node_type =~ 'controlplane' {
      file{'/var/lib/rancher/rke2/server/manifests':
        ensure   => directory,
      }

      if $rke::autostart {
        service{'rke2-server':
          enable  => $rke::autostart,
          ensure  => running,
          require => File['/etc/rancher/rke2/config.yaml'],
        }
      } else {
        service{'rke2-server':
          enable  => $rke::autostart,
          require => File['/etc/rancher/rke2/config.yaml'],
        }
      }
      service{'rke2-agent':
        enable => 'mask',
        require => File['/etc/rancher/rke2/config.yaml'],
      }
   } else {
      service{'rke2-server':
        enable => 'mask',
        require => File['/etc/rancher/rke2/config.yaml'],
      }
      if $rke::autostart {
        service{'rke2-agent':
          enable  => $rke::autostart,
          ensure  => running,
          require => File['/etc/rancher/rke2/config.yaml'],
        }
      } else {
        service{'rke2-agent':
          enable  => $rke::autostart,
          require => File['/etc/rancher/rke2/config.yaml'],
        }
      }
   }
}
