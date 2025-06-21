class rke::addon::metallb (
  String           $version         = $rke::params::metallb_version,
  Optional[Array]  $values          = $rke::params::metallb_values,
  String           $namespace       = $rke::params::metallb_namespace,
) inherits rke::params {
   
    contain rke
    contain helm

    $_path = ['/sbin','/bin','/usr/sbin','/usr/bin']
   
    helm::repo { "metallb":
        ensure            => present,
        path              => $_path,
        repo_name         => 'metallb',
        env               => $helm::env,
        repository_config => '/root/.config/helm/repositories.yaml',
        repository_cache  => '/root/.cache/helm/repository',
        url               => 'https://metallb.github.io/metallb',
    }

    helm::chart {"metallb":
        ensure            => present,
        chart             => 'metallb/metallb',
        namespace         => $namespace,
        path              => $_path,
        release_name      => 'metallb',
        env               => $helm::env,
        version           => $version,
        set               => $values,
        wait              => true,              ### wait until all pods are ready
        repository_config => '/root/.config/helm/repositories.yaml',
        repository_cache  => '/root/.cache/helm/repository',
        require           =>  Helm::Repo["metallb"], 
    }

    if $rke::cni =~ /calico/ {
      contain rke::addon::calico
 
      $_pools = $rke::addon::calico::ip_pools.map |$_pool, $_nets| {
        $_ranges = $_nets.map |$_net| { $_net['range'] }
        epp('rke/metallb-pool.yaml.epp', { 'name' => $_pool, 'ranges' => $_ranges, 'namespace' => $namespace})
      }

      file{'/var/lib/rancher/rke2/server/manifests/metallbpools.yaml':
        ensure  => file,
        content => join($_pools, "\n---\n"),
        mode    => '0600',
      }
    }
}
