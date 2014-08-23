# Copyright 2014 Red Hat, Inc., All rights reserved.
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
class openshift_origin::firewall::apache {

  if ($::openshift_origin::broker_auth_plugin == 'reverseproxy') and ('broker' in $::openshift_origin::roles) {
    lokkit::ports_from_ip4 { 'Apache reverseproxy':
      tcpPorts => ['80','443'],
      source_ips => $::openshift_origin::broker_reverseproxy_ips,
    }
  } else {
    lokkit::services { 'Apache':
      services => ['http','https'],
    }
  }
}
