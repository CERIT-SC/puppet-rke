class rke::addon::calico::hostendpoints (
  Array          $interfaces,
  Optional[Hash] $int_labels = undef,
) {
  contain rke

  @@rke::addon::calico::hostendpoint{ $facts['networking']['fqdn']:
    interfaces => $interfaces,
    int_labels => $int_labels,
    tag        => $rke::server_addr,
  }
}
