class rke::addon::etcdcleanup ( 
   Boolean $enabled = $rke::params::etcdcleanup_enabled,
) inherits rke::params  {
    if $enabled {
       package{'etcd-client':
         ensure  => present,
       }
       cron{'etcd-defrag':
         ensure  => present,
         user    => 'root',
         command => "/bin/bash -c \"ETCDCTL_ENDPOINTS='https://127.0.0.1:2379' ETCDCTL_CACERT='/var/lib/rancher/rke2/server/tls/etcd/server-ca.crt' ETCDCTL_CERT='/var/lib/rancher/rke2/server/tls/etcd/server-client.crt' ETCDCTL_KEY='/var/lib/rancher/rke2/server/tls/etcd/server-client.key' ETCDCTL_API=3 etcdctl defrag --cluster\"",
         monthday => 1,
         hour     => 10,
         minute   => 0,
       }
    }
}
