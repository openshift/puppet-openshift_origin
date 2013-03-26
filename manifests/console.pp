# == Class: openshift_origin::console
#
# Manage the OpenShift Origin console.
#
# === Parameters
#
# None
#
# === Examples
#
#  include openshift_origin::console
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
class openshift_origin::console {
  ensure_resource('package', 'rubygem-openshift-origin-console', {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource('package', 'gcc', {
      ensure  => present,
    }
  )

  ensure_resource('package', 'make', {
      ensure  => present,
    }
  )

  ensure_resource('package', 'openshift-origin-console', {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    }
  )

  file { 'openshift console.conf':
    path    => '/etc/openshift/console.conf',
    content => template('openshift_origin/console/console.conf.erb'),
    owner   => 'apache',
    group   => 'apache',
    mode    => '0644',
    require => Package['openshift-origin-console'],
  }

  $console_asset_rake_cmd = $::operatingsystem ? {
    'Fedora' => '/usr/bin/rake assets:precompile',
    default  => '/usr/bin/scl enable ruby193 "rake assets:precompile"',
  }

  $console_bundle_show    = $::operatingsystem ? {
    'Fedora' => '/usr/bin/bundle show',
    default  => '/usr/bin/scl enable ruby193 "bundle show"',
  }

  if $::operatingsystem == 'Fedora' {
    ensure_resource('package', 'rubygem-sass-rails', {
        ensure   => 'latest',
        alias    => 'rubygem-sass-rails',
      }
    )

    ensure_resource('package', 'rubygem-jquery-rails', {
        ensure   => 'latest',
        alias    => 'rubygem-jquery-rails',
      }
    )

    ensure_resource('package', 'rubygem-coffee-rails', {
        ensure   => 'latest',
        alias    => 'rubygem-coffee-rails',
      }
    )

    ensure_resource('package', 'rubygem-compass-rails', {
        ensure   => 'latest',
        alias    => 'rubygem-compass-rails',
      }
    )

    ensure_resource('package', 'rubygem-uglifier', {
        ensure   => 'latest',
        alias    => 'rubygem-uglifier',
      }
    )

    ensure_resource('package', 'rubygem-therubyracer', {
        ensure   => 'latest',
        alias    => 'rubygem-therubyracer',
      }
    )

    ensure_resource('package', 'rdiscount', {
        ensure   => '1.6.8',
        provider => 'gem',
        alias    => 'rubygem-rdiscount',
        require  => [
            Package['ruby-devel'],
            Package['gcc'],
            Package['make']
          ]
      }
    )

    ensure_resource('package', 'formtastic', {
        ensure   => '1.2.4',
        provider => 'gem',
        alias    => 'rubygem-formtastic'
      }
    )

    ensure_resource('package', 'net-http-persistent', {
        ensure   => '2.7',
        provider => 'gem',
        alias    => 'rubygem-net-http-persistent'
      }
    )

    ensure_resource('package', 'haml', {
        ensure   => '3.1.7',
        provider => 'gem',
        alias    => 'rubygem-haml'
      }
    )
  }

  if ($::operatingsystem == "RedHat" or $::operatingsystem == "CentOS") {
    ensure_resource('package', 'ruby193-rubygem-sass-rails', {
        ensure   => 'latest',
        alias    => 'rubygem-sass-rails',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-jquery-rails', {
        ensure   => 'latest',
        alias    => 'rubygem-jquery-rails',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-coffee-rails', {
        ensure   => 'latest',
        alias    => 'rubygem-coffee-rails',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-compass-rails', {
        ensure   => 'latest',
        alias    => 'rubygem-compass-rails',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-uglifier', {
        ensure   => 'latest',
        alias    => 'rubygem-uglifier',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-therubyracer', {
        ensure   => 'latest',
        alias    => 'rubygem-therubyracer',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-rdiscount', {
        ensure   => 'latest',
        alias    => 'rubygem-rdiscount',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-net-http-persistent', {
        ensure   => 'latest',
        alias    => 'rubygem-net-http-persistent',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-haml', {
        ensure   => 'latest',
        alias    => 'rubygem-haml',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-formtastic', {
        ensure   => 'latest',
        alias    => 'rubygem-formtastic',
      }
    )
  }

  exec { 'Console gem dependencies':
    cwd         => '/var/www/openshift/console/',
    command     => "${::openshift_origin::rm} -f Gemfile.lock && \
    ${console_bundle_show} && \
    ${::openshift_origin::chown} apache:apache Gemfile.lock && \
    ${::openshift_origin::rm} -rf tmp/cache/* && \
    ${console_asset_rake_cmd} && \
    ${::openshift_origin::chown} -R apache:apache /var/www/openshift/console",
    subscribe   => [
      Package['openshift-origin-console'],
      Package['rubygem-openshift-origin-console'],
      Package['rubygem-sass-rails'],
      Package['rubygem-jquery-rails'],
      Package['rubygem-uglifier'],
      Package['rubygem-coffee-rails'],
      Package['rubygem-compass-rails'],
      Package['rubygem-therubyracer'],
      Package['rubygem-rdiscount'],
      Package['rubygem-net-http-persistent'],
      Package['rubygem-haml'],
      Package['rubygem-formtastic'],
      File['openshift console.conf'],
    ],
    refreshonly => true,
  }

  if $::openshift_origin::enable_network_services == true {
    service { 'openshift-console':
      require => Package['openshift-origin-console'],
      enable  => true,
    }
  } else {
    warning 'Please ensure that openshift-console service is enable on console machines'
  }
}
