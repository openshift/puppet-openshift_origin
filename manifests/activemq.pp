# == Class: openshift_origin::activemq
#
# Install and configure ActiveMQ for OpenShift Origin.
#
# === Parameters
#
# None
#
# === Examples
#
#  include openshift_origin::activemq
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
class openshift_origin::activemq {
  include openshift_origin::params
  ensure_resource('package', 'activemq', {
      ensure  => latest,
      require => Yumrepo[openshift-origin-deps],
    }
  )

  ensure_resource('package', 'activemq-client', {
      ensure  => present,
      require => Yumrepo[openshift-origin-deps],
    }
  )

  case $::operatingsystem {
    'Fedora' : {
      file { '/etc/tmpfiles.d/activemq.conf':
        path    => '/etc/tmpfiles.d/activemq.conf',
        content => template('openshift_origin/activemq/tmp-activemq.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        require => Package['activemq'],
      }
    }
    default  : {}
  }

  file { '/var/run/activemq/':
    ensure  => 'directory',
    owner   => 'activemq',
    group   => 'activemq',
    mode    => '0750',
    require => Package['activemq'],
  }

  file { 'activemq.xml config':
    path    => '/etc/activemq/activemq.xml',
    content => template('openshift_origin/activemq/activemq.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    require => Package['activemq'],
  }

  file { 'jetty.xml config':
    path    => '/etc/activemq/jetty.xml',
    content => template('openshift_origin/activemq/jetty.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    require => Package['activemq'],
  }

  file { 'jetty-realm.properties config':
    path    => '/etc/activemq/jetty-realm.properties',
    content => template('openshift_origin/activemq/jetty-realm.properties.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    require => Package['activemq'],
  }

  if $::openshift_origin::enable_network_services == true {
    ensure_resource('service', 'activemq', {
        require    => [
          File['activemq.xml config'],
          File['jetty.xml config'],
          File['jetty-realm.properties config'],
        ],
        hasstatus  => true,
        hasrestart => true,
        enable     => true,
      }
    )
  }

  if $::openshift_origin::configure_firewall == true {
    $activemq_port = $::use_firewalld ? {
      'true'  => '61613/tcp',
      default => '61613:tcp',
    }

    exec { 'Open port for ActiveMQ':
      command => "${openshift_origin::params::firewall_port_cmd}${activemq_port}",
      require => Package['firewall-package']
    }
  }
}
