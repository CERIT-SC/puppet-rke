class rke::addon::certmanager (
  String           $version         = $rke::params::certman_version,
  Optional[Array]  $nameservers     = $rke::params::certman_nameservers,
  String           $namespace       = $rke::params::certman_namespace,
  Optional[Array]  $cluster_issuers = $rke::params::certman_clusterissuers,
) inherits rke::params {
   
    contain rke
    contain helm

    $_path = ['/sbin','/bin','/usr/sbin','/usr/bin']
   
    helm::repo { "jetstack":
        ensure            => present,
        path              => $_path,
        repo_name         => 'jetstack',
        env               => $helm::env,
        repository_config => '/root/.config/helm/repositories.yaml',
        repository_cache  => '/root/.cache/helm/repository',
        url               => 'https://charts.jetstack.io',
    }

    $_noproxy = regsubst($rke::no_proxy, ',', '\\,', 'G')
    $_nameservers = $nameservers.join('\,')

    if $rke::http_proxy {
        $_set = concat(['crds.enabled=true', "'extraArgs={--dns01-recursive-nameservers-only,--dns01-recursive-nameservers=$_nameservers,--enable-certificate-owner-ref=false}'"], 
                        "http_proxy=${rke::http_proxy}", "https_proxy=${rke::http_proxy}", "'no_proxy=${_noproxy}'")
    } else {
        $_set = ['crds.enabled=true', "'extraArgs={--dns01-recursive-nameservers-only,--dns01-recursive-nameservers=$_nameservers,--enable-certificate-owner-ref=false}'"]
    }

    helm::chart {"cert-manager":
        ensure            => present,
        chart             => 'jetstack/cert-manager',
        namespace         => $namespace,
        path              => $_path,
        release_name      => 'cert-manager',
        env               => $helm::env,
        version           => $version,
        set               => $_set,
        wait              => true,              ### wait until all pods are ready
        repository_config => '/root/.config/helm/repositories.yaml',
        repository_cache  => '/root/.cache/helm/repository',
        require           =>  Helm::Repo["jetstack"], 
    }

    if $rke::config::dns_secret {
        rke::k8sresource::deploy {'letsencrypt-dns-secret':
          filename => '/var/lib/rancher/rke2/server/values/dns-secret-le.yaml',
          content  => epp('rke/dns-secret.yaml', {'name' => 'tsig-secret', 'namespace' => $namespace, 'key' => $rke::config::dns_secret}),
        }
    }

    if $cluster_issuers {
       $cluster_issuers.each |$_issuer| {
          rke::k8sresource::deploy {"le-clusterissuer-${_issuer['name']}":
            filename => "/var/lib/rancher/rke2/server/values/le-clusterissuer-${_issuer['name']}",
            content  => epp('rke/le-clusterissuer.yaml', {'dnsissuer'    => $_issuer['name'],
                                                          'email'        => $_issuer['email'],
                                                          'secretref'    => $_issuer['name'],
                                                          'serverurl'    => $_issuer['url'],
                                                          'nameserver'   => $_issuer['nameserver'],
                                                          'keyalgo'      => $_issuer['keyalgo'],
                                                          'keyname'      => $_issuer['keyname'],
                                                          'tsigsecret'   => 'tsig-secret',
                                                          'domain'       => $_issuer['domain'],
                                                          'ingressclass' => $_issuer['ingressclass'],
                                                         }),
          }
       }
    }
}
