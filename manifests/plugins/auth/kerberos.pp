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
class openshift_origin::plugins::auth::kerberos {
  ensure_resource('package', 'rubygem-openshift-origin-auth-remote-user', {
      ensure  => present,
      require => Class['openshift_origin::install_method'],
    }
  )

  package { 'mod_auth_kerb':
    ensure => installed,
  }
  
  file {'broker http keytab':
    ensure => present,
    path => $::openshift_origin::broker_krb_keytab,
    owner => 'apache',
    group => 'apache',
    mode => '0644',
    require => Package['rubygem-openshift-origin-auth-remote-user']
  }

  file {'broker kerbros.conf':
    path => '/var/www/openshift/broker/httpd/conf.d/openshift-origin-auth-remote-user-kerberos.conf',
    content => 
      template('openshift_origin/broker/plugins/auth/kerberos/openshift-origin-auth-remote-user-kerberos.conf.erb'),
    owner => 'apache',
    group => 'apache',
    mode => '0644',
    require => [
      Package['rubygem-openshift-origin-auth-remote-user'],
      Package['mod_auth_kerb'],
      File['broker http keytab']
    ],
    notify  => Service['openshift-broker'],    
    before  => Exec['Broker gem dependencies'],
  }

  file {'console kerberos.conf':
    path => '/var/www/openshift/console/httpd/conf.d/openshift-origin-auth-remote-user-kerberos.conf',
    content =>
      template('openshift_origin/console/plugins/auth/kerberos/openshift-origin-auth-remote-user-kerberos.conf.erb'),
    owner => 'apache',
    group => 'apache',
    mode => '0644',
    require => [
      Package['rubygem-openshift-origin-auth-remote-user'],
      Package['mod_auth_kerb'],
      File['broker http keytab']
    ],
    notify  => Service['openshift-console'],    
    before  => Exec['Console gem dependencies'],
  }

  file { 'Auth plugin config':
    path    => '/etc/openshift/plugins.d/openshift-origin-auth-remote-user.conf',
    content => template('openshift_origin/broker/plugins/auth/basic/remote-user.conf.plugin.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['rubygem-openshift-origin-auth-remote-user']
    before  => Exec['Broker gem dependencies'],
  }
}
