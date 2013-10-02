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
class openshift_origin::plugins::container::libvirt {
  ensure_resource('package', 'libvirt-daemon', {
      ensure  => present,
      require => Yumrepo['openshift-origin'],
    }
  )
  
  ensure_resource('package', 'libvirt-sandbox', {
      ensure  => present,
    }
  )
  
  service { 'libvirtd':
    enable  => true,
    require => [Package['libvirt-daemon'], Package['libvirt-sandbox']]
  }
}
