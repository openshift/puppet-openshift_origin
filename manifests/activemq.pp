# Copyright 2013 Mojo Lingo LLC.
# Modifications by Red Hat, Inc.
# 
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
class openshift_origin::activemq {
  include openshift_origin::params
  ensure_resource('package', 'activemq', {
      ensure  => present,
      require => Class['openshift_origin::install_method'],
    }
  )

  ensure_resource('package', 'activemq-client', {
      ensure  => present,
      require => Class['openshift_origin::install_method'],
    }
  )

  if $::operatingsystem == 'Fedora' {
    file { '/etc/tmpfiles.d/activemq.conf':
      path    => '/etc/tmpfiles.d/activemq.conf',
      content => template('openshift_origin/activemq/tmp-activemq.conf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      require => Package['activemq'],
    }
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

  firewall{ 'activemq':
    port      => '61613',
    protocol  => 'tcp',
  }
}
