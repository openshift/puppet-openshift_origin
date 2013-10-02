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
class openshift_origin::plugins::frontend::apache {

  ensure_resource ( 'package', 'httpd', {} )

  service { 'httpd':
    enable  => true,
    require =>  Package['httpd'],
  }
  
  file { 'node servername config':
    ensure  => present,
    path    => '/etc/httpd/conf.d/000001_openshift_origin_node_servername.conf',
    content => template('openshift_origin/plugins/frontend/apache/openshift-origin-node_servername.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['rubygem-openshift-origin-node'],
  }
  
  if $::operatingsystem == "Fedora" {
    file { 'allow cartridge files through apache':
      ensure  => present,
      path    => '/etc/httpd/conf.d/cartridge_files.conf',
      content => template('openshift_origin/plugins/frontend/apache/cartridge_files.conf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0660',
      require =>  Package['httpd'],
    }
  }
}
