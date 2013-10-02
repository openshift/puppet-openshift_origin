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
class openshift_origin::plugins::frontend::apache_mod_rewrite {
  include ::openshift_origin::params

  ensure_resource( 'package', 'rubygem-openshift-origin-frontend-apache-mod-rewrite', {} )
  
  include openshift_origin::plugins::frontend::apache

  if member( $openshift_origin::roles, 'broker' ) {
    file { 'broker and console route for node':
      ensure  => present,
      path    => '/tmp/nodes.broker_routes.txt',
      content => template('openshift_origin/plugins/frontend/apache_mod_rewrite/node_routes.txt.erb'),
      owner   => 'root',
      group   => 'apache',
      mode    => '0640',
      require => [
        Package['rubygem-openshift-origin-frontend-apache-mod-rewrite'],
      ],
    }
    
    exec { 'regen node routes':
      command => "${::openshift_origin::params::cat} /etc/httpd/conf.d/openshift/nodes.txt /tmp/nodes.broker_routes.txt > /etc/httpd/conf.d/openshift/nodes.txt.new && \
                  ${::openshift_origin::params::mv} /etc/httpd/conf.d/openshift/nodes.txt.new /etc/httpd/conf.d/openshift/nodes.txt && \
                  ${::openshift_origin::params::httxt2dbm} -f DB -i /etc/httpd/conf.d/openshift/nodes.txt -o /etc/httpd/conf.d/openshift/nodes.db.new && \
                  ${::openshift_origin::params::chown} root:apache /etc/httpd/conf.d/openshift/nodes.txt /etc/httpd/conf.d/openshift/nodes.db.new && \
                  ${::openshift_origin::params::chmod} 750 /etc/httpd/conf.d/openshift/nodes.txt /etc/httpd/conf.d/openshift/nodes.db.new && \
                  ${::openshift_origin::params::mv} -f /etc/httpd/conf.d/openshift/nodes.db.new /etc/httpd/conf.d/openshift/nodes.db",
      unless  => "${::openshift_origin::params::grep} '__default__/broker' /etc/httpd/conf.d/openshift/nodes.txt 2>/dev/null",
      require => File['broker and console route for node'],
    }
  }
}