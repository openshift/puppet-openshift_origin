# == Class: openshift_origin::firewall::node
#
# Setup the required firewall rules and IPTables chains for a working OpenShift node.
#
# === Parameters
#
# None
#
# === Examples
#
#  include ::openshift_origin::firewall::node
#
# === Copyright
#
# Copyright 2014 Red Hat, Inc.
#
# === License
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class openshift_origin::firewall::node {
  lokkit::custom { 'openshift_node_rules':
    type   => 'ipv4',
    table  => 'filter',
    source => 'puppet:///openshift_origin/firewall/node_iptables.txt',
  }

  lokkit::custom { 'rhc-app-comm_chain':
    ensure => present,
    type   => 'ipv4',
    source => 'puppet:///openshift_origin/node/node_iptables.txt',
  }
}
