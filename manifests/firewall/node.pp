class openshift_origin::firewall::node {
  lokkit::custom { 'openshift_node_rules':
    type   => 'ipv4',
    table  => 'filter',
    source => 'puppet:///modules/openshift_origin/firewall/node_iptables.txt',
  }
}
