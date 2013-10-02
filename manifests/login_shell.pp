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
class openshift_origin::login_shell {
  include openshift_origin::params
  
  if ($::operatingsystem != 'Fedora') {
    fail 'Custom OpenShift Origin shell is only available on Fedora systems'
  }

  ensure_resource('package', 'rubygem-highline', {
      ensure   => 'present',
      require => Class['openshift_origin::install_method'],
    }
  )

  ensure_resource('package', 'rubygem-httpclient', {
      ensure   => 'present',
      require => Class['openshift_origin::install_method'],
    }
  )

  file { 'getty.service':
    ensure  => present,
    path    => '/usr/lib/systemd/system/getty@.service',
    content => template('openshift_origin/login_shell/getty@.service'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
  
  file { '/usr/bin/oo-login':
    ensure  => present,
    path    => '/usr/bin/oo-login',
    content => template('openshift_origin/login_shell/oo-login'),
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
  }
}
