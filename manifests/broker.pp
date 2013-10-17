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
class openshift_origin::broker {
  ensure_resource('package', [
      'openshift-origin-broker',
      'openshift-origin-broker-util',
      'rubygem-openshift-origin-msg-broker-mcollective',
      'rubygem-openshift-origin-admin-console',      
      "rubygem-openshift-origin-dns-${::openshift_origin::broker_dns_plugin}",
    ], {
      ensure  => present,
      require => Class['openshift_origin::install_method'],
    }
  )
  
  # We combine these setsebool commands into a single semanage command
  # because separate commands take a long time to run.
  exec { 'broker selinux booleans':
    command  => template('openshift_origin/selinux/broker.erb'),
    provider => 'shell'
  }

  case $::openshift_origin::broker_dns_plugin {
    'nsupdate' : { include openshift_origin::plugins::dns::nsupdate }
    'avahi'    : { include openshift_origin::plugins::dns::avahi }
  }
  
  case $::openshift_origin::broker_auth_plugin {
    'mongo'       : { include openshift_origin::plugins::auth::mongo }
    'htpasswd'    : { include openshift_origin::plugins::auth::htpasswd }    
    'kerberos'    : { include openshift_origin::plugins::auth::kerberos }    
  }

  include openshift_origin::mcollective_client

  if $::openshift_origin::conf_broker_auth_public_key == undef {
    exec { 'Generate self signed keys for broker auth':
      command => '/bin/mkdir -p /etc/openshift && \
                 /usr/bin/openssl genrsa -out /etc/openshift/server_priv.pem 2048 && \
                 /usr/bin/openssl rsa -in /etc/openshift/server_priv.pem -pubout > \
                 /etc/openshift/server_pub.pem',
      creates => '/etc/openshift/server_pub.pem',
    }
  } else {
    file { 'broker auth public key':
      ensure  => present,
      path    => '/etc/openshift/server_pub.pem',
      content => source($::openshift_origin::conf_broker_auth_public_key),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['openshift-origin-broker'],
    }

    file { 'broker auth private key':
      ensure  => present,
      path    => '/etc/openshift/server_priv.pem',
      content => source($::openshift_origin::conf_broker_auth_private_key),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['openshift-origin-broker'],
    }
  }
  
  file { 'broker servername config':
    ensure  => present,
    path    => '/etc/httpd/conf.d/000000_openshift_origin_broker_servername.conf',
    content => template('openshift_origin/broker/broker_servername.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['openshift-origin-broker'],
  }
  
  file { 'mcollective broker plugin config':
    ensure  => present,
    path    => '/etc/openshift/plugins.d/openshift-origin-msg-broker-mcollective.conf',
    content => template('openshift_origin/broker/msg-broker-mcollective.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['rubygem-openshift-origin-msg-broker-mcollective'],
  }

  file { 'openshift broker.conf':
    path    => '/etc/openshift/broker.conf',
    content => template('openshift_origin/broker/broker.conf.erb'),
    owner   => 'apache',
    group   => 'apache',
    mode    => '0644',
    require => Package['openshift-origin-broker'],
  }

  if $::openshift_origin::development_mode == true {
    file { 'openshift broker-dev.conf':
      path    => '/etc/openshift/broker-dev.conf',
      content => template('openshift_origin/broker/broker.conf.erb'),
      owner   => 'apache',
      group   => 'apache',
      mode    => '0644',
      require => Package['openshift-origin-broker'],
    }
  }

  exec { 'restorecon -vr /var/log/openshift':
    provider  => 'shell',
    require   => Package['openshift-origin-broker'],
  }
  
  $broker_bundle_show = $::operatingsystem ? {
    'Fedora' => '/usr/bin/bundle show',
    default  => '/usr/bin/scl enable ruby193 "bundle show"',
  }

  # This File resource is to guarantee that the Gemfile.lock created
  # by the following Exec has the appropriate permissions (otherwise
  # it is created as owned by root:root)  
  file { '/var/www/openshift/broker/Gemfile.lock':
    ensure    => 'present',
    owner     => 'apache',
    group     => 'apache',
    mode      => '0644',
    subscribe => Exec ['Broker gem dependencies'],
    require   => Exec ['Broker gem dependencies'],
  }

  exec { 'Broker gem dependencies':
    cwd     => '/var/www/openshift/broker/',
    command => "${::openshift_origin::params::rm} -f Gemfile.lock && \
    ${broker_bundle_show} && \
    ${::openshift_origin::params::chown} apache:apache Gemfile.lock && \
    ${::openshift_origin::params::rm} -rf tmp/cache/*",
    unless  => $broker_bundle_show,
    require => [
      Package['openshift-origin-broker'],
      File['openshift broker.conf'],
      File['mcollective broker plugin config'],
    ],
  }

  service { 'openshift-broker':
    require => [Package['openshift-origin-broker']],
    enable  => true,
  }

  if $::openshift_origin::install_login_shell {
    include openshift_origin::login_shell
  }
  
  ensure_resource( 'firewall', 'http', {
      service => 'http',
    }
  )
  
  ensure_resource( 'firewall', 'https', {
      service => 'https',
    }
  )
}
