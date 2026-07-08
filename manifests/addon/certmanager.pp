class rke::addon::certmanager (
  Optional[Array]  $cluster_issuers = $rke::params::certman_clusterissuers,
  Boolean          $gateway_api     = $rke::params::certman_gatewayapi,
  Optional[Array]  $issuers         = $rke::params::certman_issuers,
  Boolean          $listenersets    = $rke::params::certman_listenersets,
  String           $namespace       = $rke::params::certman_namespace,
  Optional[Array]  $nameservers     = $rke::params::certman_nameservers,
  String           $version         = $rke::params::certman_version,
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

    if $rke::no_proxy {
       $_noproxy = regsubst($rke::no_proxy, ',', '\\,', 'G')
    } else {
       $_noproxy = undef
    }
    
    if $nameservers != undef {
        $_nameservers = $nameservers.join('\,')

        if $rke::http_proxy {
            $_set = concat(['crds.enabled=true', "'extraArgs={--dns01-recursive-nameservers-only,--dns01-recursive-nameservers=$_nameservers,--enable-certificate-owner-ref=false}'", 'config.featureGates.ACMEHTTP01IngressPathTypeExact=false'], 
                        "http_proxy=${rke::http_proxy}", "https_proxy=${rke::http_proxy}", "'no_proxy=${_noproxy}'")
        } else {
           $_set = ['crds.enabled=true', "'extraArgs={--dns01-recursive-nameservers-only,--dns01-recursive-nameservers=$_nameservers,--enable-certificate-owner-ref=false}'", 'config.featureGates.ACMEHTTP01IngressPathTypeExact=false']
        }
    } else {
        if $rke::http_proxy {
            $_set = concat(['crds.enabled=true', "'extraArgs={--enable-certificate-owner-ref=false}'", 'config.featureGates.ACMEHTTP01IngressPathTypeExact=false'],
                        "http_proxy=${rke::http_proxy}", "https_proxy=${rke::http_proxy}", "'no_proxy=${_noproxy}'")
        } else {
           $_set = ['crds.enabled=true', "'extraArgs={--enable-certificate-owner-ref=false}'", 'config.featureGates.ACMEHTTP01IngressPathTypeExact=false']
        }
    }

    $_set_final = concat(
        $_set,
        $gateway_api ? { true => ['config.enableGatewayAPI=true'], default => [] },
        $listenersets ? { true => ['config.enableGatewayAPIListenerSet=true', 'config.featureGates.ListenerSets=true'], default => [] },
    )

    helm::chart {"cert-manager":
        ensure            => present,
        chart             => 'jetstack/cert-manager',
        namespace         => $namespace,
        path              => $_path,
        release_name      => 'cert-manager',
        env               => $helm::env,
        version           => $version,
        set               => $_set_final,
        wait              => true,              ### wait until all pods are ready
        repository_config => '/root/.config/helm/repositories.yaml',
        repository_cache  => '/root/.cache/helm/repository',
        require           =>  Helm::Repo["jetstack"], 
    }

    if $rke::config::dns_secret {
        file{'/var/lib/rancher/rke2/server/manifests/dns-secret-le.yaml':
          ensure   => file,
          content  => epp('rke/dns-secret.yaml', {'name' => 'tsig-secret', 'namespace' => $namespace, 'key' => $rke::config::dns_secret}),
          mode     => '0600',
        }
    }

    if $cluster_issuers {
       $cluster_issuers.each |$_issuer| {
            file{"/var/lib/rancher/rke2/server/manifests/le-clusterissuer-${_issuer['name']}.yaml":
              ensure   => file,
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
              mode     => '0600',
          }
       }
    }
    if $issuers {
       $issuers.each |$_issuer| {
            file{"/var/lib/rancher/rke2/server/manifests/le-issuer-${_issuer['name']}.yaml":
              ensure   => file,
              content  => epp('rke/le-issuer.yaml', {'dnsissuer'    => $_issuer['name'],
                                                            'email'        => $_issuer['email'],
                                                            'secretref'    => $_issuer['name'],
                                                            'serverurl'    => $_issuer['url'],
                                                            'nameserver'   => $_issuer['nameserver'],
                                                            'keyalgo'      => $_issuer['keyalgo'],
                                                            'keyname'      => $_issuer['keyname'],
                                                            'tsigsecret'   => 'tsig-secret',
                                                            'domain'       => $_issuer['domain'],
                                                            'ingressclass' => $_issuer['ingressclass'],
                                                            'namespace'    => $_issuer['namespace'],
                                                           }),
              mode     => '0600',
          }
          if $rke::config::dns_secret {
             file{"/var/lib/rancher/rke2/server/manifests/dns-secret-le-${_issuer['namespace']}.yaml":
               ensure   => file,
               content  => epp('rke/dns-secret.yaml', {'name' => 'tsig-secret', 'namespace' => $_issuer['namespace'], 'key' => $rke::config::dns_secret}),
               mode     => '0600',
             }
          }
       }
    }
}
