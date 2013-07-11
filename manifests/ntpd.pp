# == Class: openshift_origin::ntpd
#
# Provides a basic ntp setup. The clocks between all nodes and broker machines
# must be kept in sync for mcollecitve message to be processed properly
#
# === Parameters
#
# None
#
# === Examples
#
#  include openshift_origin::ntpd
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
class openshift_origin::ntpd (
  $example = undef) {
    ensure_resource('package', 'ntpdate', {
      ensure => 'latest',
    }
  )

  class { 'ntp':
    servers    => ['time.apple.com iburst', 'pool.ntp.org iburst', 'clock.redhat.com iburst'],
    autoupdate => true,
  }
}
