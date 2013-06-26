# == Class: openshift_origin::qpidd
#
# Manage QPid for OpenShift Origin.
#
# === Parameters
#
# None
#
# === Examples
#
#  include openshift_origin::qpidd
#
# === Copyright
#
# Copyright 2013 Mojo Lingo LLC.
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
class openshift_origin::qpidd {
  include openshift_origin::params
  ensure_resource('package', 'qpid-cpp-server', {
      ensure => present,
    }
  )
  ensure_resource('package', 'mcollective-qpid-plugin', {
      ensure => present,
    }
  )

  file { '/etc/qpidd.conf':
    content => template('openshift_origin/qpid/qpidd.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['qpid-cpp-server'],
  }

  if $::openshift_origin::enable_network_services == true {
    service { 'qpidd':
      require => File['/etc/qpidd.conf'],
      enable  => true,
    }
  }

  if $::openshift_origin::configure_firewall == true {
    $qpid_port = $::use_firewalld ? {
      true    => '5672/tcp',
      default => '5672:tcp',
    }

    exec { 'Open port for Qpid':
      command => "${openshift_origin::params::firewall_port_cmd}${qpid_port}",
      require => Package['firewall-package'],
    }
  }
}
