# == Class: openshift_origin::params
#
# Variables for use in other <code>openshift_origin</code> classes.
#
# === Parameters
#
# None
#
# === Examples
#
#  include openshift_origin::params
#
# === Copyright
#
# Copyright 2013 Red Hat, Inc.
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
class openshift_origin::params {
  # Make sure the tools needed to manage the firewall are installed
  $firewall_package     = $::use_firewalld ? {
    'true'  => 'firewalld',
    default => 'system-config-firewall-base',
  }

  # Set the base firewall command for enableling services
  $firewall_service_cmd = $::use_firewalld ? {
    'true'  => '/usr/bin/firewall-cmd --permanent --zone=public --add-service=',
    default => '/usr/sbin/lokkit --service=',
  }

  # Set the base firewall command for enableling services
  $firewall_port_cmd    = $::use_firewalld ? {
    'true'  => '/usr/bin/firewall-cmd --permanent --zone=public --add-port=',
    default => '/usr/sbin/lokkit --port=',
  }
}
