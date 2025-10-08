class rke::config::main (
   String $file = $rke::params::rke2_config,
) inherits rke::params {

   $_configdir = dirname($file)
   exec {'mkdir-config':
      command => "mkdir -p ${_configdir}",
      unless  => "test -d ${_configdir}",
   }

   if defined(Package['rke2']) {
      $_require = Package['rke2']
   } else {
      $_require = Package_versionlock['rke2']
   }

   if ! $rke::node_ip_auto {
     if $rke::node_iface {
       $_ipv4 = $facts["networking"]['interfaces'][$rke::node_iface]['bindings'].map |$_binding| {
         if $rke::node_ip_skip_mask {
           if ($_binding['netmask'] !~ /255$/) and ($_binding['address'] !~ Regexp($rke::node_ip_skip_mask)) {
             $_binding['address']
           }
         } else {
           if $_binding['netmask'] !~ /255$/ {
              $_binding['address']
           }
         }
       }
       if $_ipv4 == undef {
         notify{"Cannot detect IPv4 on interface ${$rke::node_iface}":}
       }
     } else {
       $_ipv4 = undef
     }

     if $rke::node_iface6 {
       $_ipv6 = $facts["networking"]['interfaces'][$rke::node_iface6]['bindings6'].map |$_binding| {
         if $_binding['netmask'] =~ /::$/ and $_binding['scope6'] == "global" {
            $_binding['address']
         }
       }
       if $_ipv6 == undef {
         notify{"Cannot detect IPv6 on interface ${$rke::node_iface6}":}
       }
     } else {
       $_ipv6 = undef
     }
    
     if $_ipv6 != undef or $_ipv4 != undef {
       $_nodeip = delete_undef_values(flatten($_ipv4, $_ipv6)).join(',')
     } else {
       $_nodeip = undef
     }
   } else {
     $_nodeip = undef
   }

   if $rke::token == undef {
     $_tokens = puppetdb_query("resources{type='Rke::Token' and tag='${rke::server_addr}'}").map |$resource| {
                        $resource['parameters']['clustertoken']
              }
     if $_tokens != undef {
        $_token = $_tokens[0]
     } else {
        $_token = undef
     }
   } else {
     $_token = $rke::token
   }

   if $rke::node_type =~ /controlplane/ {
     if $rke::server_addr != $facts['clusterfullname'] {
       $_tlsnames = [$facts['networking']['fqdn'], $facts['clusterfullname'], $rke::server_addr]
     } else {
       $_tlsnames = [$facts['networking']['fqdn'], $facts['clusterfullname']]
     }
   } else {
      $_tlsnames = undef
   }

   if $rke::scheduler_policy {
     file{'/var/lib/rancher/rke2/server/sched':
       ensure => directory,
     }
     if $rke::scheduler_extenders {
       $_extenders = $rke::scheduler_extenders.map |$_extender| { 
         regsubst(regsubst(regsubst(to_yaml($_extender, {indentation => 2}), '^---\n', '', 'M'), '^', '  ', 'GM'), '^  ', '')
       }
     } else {
       $_extenders = undef
     }
     if $rke::scheduler_profiles {
       $_profiles = $rke::scheduler_profiles.map |$_profile| {
         regsubst(regsubst(regsubst(to_yaml($_profile, {indentation => 2}), '^---\n', '', 'M'), '^', '  ', 'GM'), '^  ', '')
       }
     } else {
       $_profiles = undef
     }
     file{'/var/lib/rancher/rke2/server/sched/scheduler-policy-config.yaml':
       ensure  => file,
       content => epp('rke/scheduler-policy-config.yaml.epp', {'extenders' => $_extenders, 'profiles' => $_profiles }),
       require => File['/var/lib/rancher/rke2/server/sched'],
     }
   } else {
     file{'/var/lib/rancher/rke2/server/sched/scheduler-policy-config.yaml':
       ensure => absent,
     }
   }

   if $rke::node_type =~ 'controlplane' {
      if $rke::static_cpu_policy == 'true' or $rke::static_cpu_policy == 'reserveonly' {
         $_reservecpu = "reserved-cpus=${rke::static_reserved_cpus}"
      } else {
         $_reservecpu = undef
      }
    } else {
      if $rke::static_cpu_policy == 'true' or $rke::static_cpu_policy == 'reserveonly' {
        $_reservecpu = ["system-reserved=memory=8Gi", "reserved-cpus=${rke::static_reserved_cpus}"]
      } else {
         $_reservecpu = undef
      }
    }

    if $rke::node_max_pods {
       $_mpods = "max-pods=${rke::node_max_pods}"
    } else {
       $_mpods = undef
    }

    if $rke::kubeapi_qps {
       $_kaqps = "kube-api-qps=${rke::kubeapi_qps}"
    } else {
       $_kaqps = undef
    }

    if $rke::kubeapi_burst {
       $_kaburst = "kube-api-burst=${rke::kubeapi_burst}"
    } else {
       $_kaburst = undef
    }

    if $rke::static_cpu_policy and $rke::static_cpu_policy == 'true' {
       $_kubeletargs = delete_undef_values(flatten([$_reservecpu, $_mpods, $_kaqps, $_kaburst, $rke::kubelet_args, "cpu-manager-policy=static", "topology-manager-policy=best-effort"]))
    } else {
       $_kubeletargs = delete_undef_values(flatten([$_reservecpu, $_mpods, $_kaqps, $_kaburst, $rke::kubelet_args]))
    }

   file{$file:
      ensure    => file,
      content   => epp('rke/rke2-config.yaml.epp', { 'server'               => $rke::server_addr,
                                                     'taint'                => $rke::node_taint,
                                                     'token'                => $_token,
                                                     'labels'               => $rke::node_labels,
                                                     'profile'              => $rke::cis_profile,
                                                     'schedulerpolicy'      => $rke::scheduler_policy,
                                                     'tlsnames'             => $_tlsnames,
                                                     'auditlog'             => $rke::auditlog_enable,
                                                     'auditlogfile'         => $rke::config::audit_log_file,
                                                     'nodeip'               => $_nodeip,
                                                     'controlplanerequests' => $rke::controlplane_requests,
                                                     'internalingress'      => $rke::internal_ingress,
                                                     'nodetype'             => $rke::node_type,
                                                     'kubeletargs'          => $_kubeletargs,
                                                     'clustercidr'          => $rke::cluster_cidr,
                                                     'servicecidr'          => $rke::service_cidr,
                                                     'nodev6cidr'           => $rke::nodev6_cidr,
                                                     'cni'                  => $rke::cni,
                                                     'disableproxy'         => $rke::disable_kubeproxy,
                                                     'psaconfig'            => $rke::config::pss_file,
                                                     'etcds3accesskey'      => $rke::etcd_s3_accesskey,
                                                     'etcds3secretkey'      => $rke::etcd_s3_secretkey,
                                                     'etcds3endpoint'       => $rke::etcd_s3_endpoint,
                                                     'etcds3path'           => $rke::etcd_s3_path,
                                                     'etcdarg'              => "quota-backend-bytes=${rke::etcd_quota_backend}",
                                                     'kubeconfig'           => $rke::config::kubelet_config_file,
                                                     'tlssecurity'          => $rke::tls_security,
                                                     'kubeletfgates'        => $rke::kubelet_gates,
                                                     'kubeapifgates'        => $rke::kubeapi_gates,
                                                     'controllerfgates'     => $rke::controller_gates,
                                                     'schedulerfgates'      => $rke::scheduler_gates,
                                                    }),
      require   => $_require,
      show_diff => false,
      mode      => '0600',
   }
}
