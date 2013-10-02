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
class openshift_origin::mcollective_client {
  include openshift_origin::params
  
  ensure_resource( 'package' , "${::openshift_origin::params::ruby_scl_prefix}mcollective-client", {
      alias => 'mcollective-client',
    } 
  )

  file { 'mcollective client config':
    ensure  => present,
    path    => "${::openshift_origin::params::ruby_scl_path_prefix}/etc/mcollective/client.cfg",
    content => template('openshift_origin/mcollective/mcollective-client.cfg.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['mcollective-client'],
  }
}
