class rke::addon::externaldns (
   String  $dnssecret    = $rke::params::externaldns_dnssecret,
   String  $namespace    = $rke::params::externaldns_namespace,
   String  $server       = $rke::params::externaldns_server,
   String  $domain       = $rke::params::externaldns_domain,
   String  $keyalgo      = $rke::params::externaldns_keyalgo,
   String  $keyname      = $rke::params::externaldns_keyname,
   String  $domainfilter = $rke::params::externaldns_domainfilter,
   String  $imageversion = $rke::params::externaldns_imageversion,
   String  $tag          = $rke::params::externaldns_tag,
) inherits rke::params {
    file{'/var/lib/rancher/rke2/server/manifests/externaldns-secret.yaml':
        ensure   => file,
        content  => epp('rke/dns-secret.yaml', {"name" => "dnssecret", "namespace" => $namespace, "key" => $dnssecret}),
        mode     => '0600',
    }
    file{'/var/lib/rancher/rke2/server/manifests/externaldns.yaml':
        ensure   => file,
        content  => epp('rke/externaldns.yaml', {"namespace" => $namespace, "dnsserver" => $server, "domain" => $domain,
                                                  "key" => $keyalgo, "keyname" => $keyname, "domainfilter" => $domainfilter,
                                                  "dnssecret" => "dnssecret", "tagsuffix" => $tag, 
                                                  "version" => $imageversion}),
        mode     => '0600',
    }
}

