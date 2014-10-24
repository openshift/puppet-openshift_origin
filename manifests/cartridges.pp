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
class openshift_origin::cartridges {
  package { 'yum-plugin-versionlock':
    ensure  => present,
  }

  openshift_origin::openshift_cartridge { $::openshift_origin::install_cartridges: }
  
  $recommended_deps = prefix($::openshift_origin::install_cartridges_recommended_deps, 'openshift-origin-cartridge-dependencies-recommended-')
  package { $recommended_deps:
    ensure  => present,
  }

  if $::openshift_origin::install_cartridges_optional_deps != undef {
    $optional_deps = prefix($::openshift_origin::install_cartridges_optional_deps, 'openshift-origin-cartridge-dependencies-optional-')
    package { $optional_deps:
      ensure  => present,
    }
  }
    
  if $::openshift_origin::development_mode == true {
    openshift_origin::openshift_cartridge { [ 'mock', 'mock-plugin' ]: }
  }
}
