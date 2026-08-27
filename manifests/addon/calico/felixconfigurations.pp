class rke::addon::calico::felixconfigurations {
  contain rke

  if $rke::node_iface {
    $_ipv4_bindings = $facts['networking']['interfaces'][$rke::node_iface]['bindings'].map |$_binding| {
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
    $_ipv4 = delete_undef_values($_ipv4_bindings)[0]
  } else {
    $_ipv4 = undef
  }

  if $rke::node_iface6 {
    $_ipv6_bindings = $facts['networking']['interfaces'][$rke::node_iface6]['bindings6'].map |$_binding| {
      if $_binding['netmask'] =~ /::$/ and $_binding['scope6'] == 'global' {
        $_binding['address']
      }
    }
    $_ipv6 = delete_undef_values($_ipv6_bindings)[0]
  } else {
    $_ipv6 = undef
  }

  @@rke::addon::calico::felixconfiguration{ $facts['networking']['fqdn']:
    ipv4 => $_ipv4,
    ipv6 => $_ipv6,
    tag  => $rke::server_addr,
  }
}
