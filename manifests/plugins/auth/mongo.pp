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
class openshift_origin::plugins::auth::mongo {
  ensure_resource('package', 'rubygem-openshift-origin-auth-mongo', {
      ensure  => present,
      require => Class['openshift_origin::install_method'],
    }
  )

  file { 'Auth plugin config':
    ensure  => present,
    path    => '/etc/openshift/plugins.d/openshift-origin-auth-mongo.conf',
    content => template('openshift_origin/broker/plugins/auth/mongo/mongo.conf.plugin.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['rubygem-openshift-origin-msg-broker-mcollective'],
    before  => Exec['Broker gem dependencies'],
  }
}
