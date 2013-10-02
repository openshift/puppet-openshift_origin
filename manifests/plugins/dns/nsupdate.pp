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
class openshift_origin::plugins::dns::nsupdate {
  if $::openshift_origin::bind_key == '' and !$::openshift_origin::bind_krb_principal {
    warning "Generate the Key file with '/usr/sbin/dnssec-keygen -a HMAC-MD5 -b 512 -n USER -r /dev/urandom -K /var/named ${::openshift_origin::domain}'"
    warning "Use the last field in the generated key file /var/named/K${openshift_origin::domain}*.key"
    fail 'bind_key is required.'
  }
  if $::openshift_origin::bind_krb_principal and $::openshift_origin::bind_krb_keytab == '' {
    warning "Kerberos keytab for the DNS service was not found. Please generate a keytab for DNS/${::openshift_origin::named_hostname}"
    fail "bind_krb_keytab is required."
  }

  ensure_resource( 'package' , 'rubygem-openshift-origin-dns-nsupdate', {
      require => Class['openshift_origin::install_method'],
    } 
  )

  if $::openshift_origin::broker_dns_gsstsig {
    file { 'broker-dns-keytab':
      ensure => present,
      path => $::openshift_origin::bind_krb_keytab,
      owner => 'apache',
      group => 'apache',
      mode => '0664',
      require => Package['rubygem-openshift-origin-dns-nsupdate'],
    }
    file { 'plugin openshift-origin-dns-nsupdate.conf':
      path   => '/etc/openshift/plugins.d/openshift-origin-dns-nsupdate.conf',
      content => template('openshift_origin/broker/plugins/dns/nsupdate/nsupdate-kerb.conf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => [
        Package['rubygem-openshift-origin-dns-nsupdate'],
        File['broker-dns-keytab'],
      ]
    }
  } else {
    file { 'plugin openshift-origin-dns-nsupdate.conf':
      path    => '/etc/openshift/plugins.d/openshift-origin-dns-nsupdate.conf',
      content => template('openshift_origin/broker/plugins/dns/nsupdate/nsupdate.conf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['rubygem-openshift-origin-dns-nsupdate'],
    }
  }
}
