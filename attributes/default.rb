#
# Author:: anthony ryan <anthony@tentric.com>
# Cookbook Name:: zend
#
# Copyright 2014, Anthony Ryan
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# set info
case node[:platform]
when 'redhat','centos','fedora','amazon'
  default['zend']['webuser'] = "www-data"
  default['zend']['webgroup'] = "www-data"
  default['zend']['apachepid'] = "httpd"
  default['zend']['apachedir'] = "/etc/httpd"
  default['zend']['phpdir'] = "/etc/php"
  default['zend']['nginxdir'] = "/etc/nginx"
when 'gentoo'
  default['zend']['webuser'] = "apache"
  default['zend']['webgroup'] = "apache"
  default['zend']['apachepid'] = "apache2"
  default['zend']['apachedir'] = "/etc/apache2"
  default['zend']['phpdir'] = "/etc/php"
  default['zend']['nginxdir'] = "/etc/nginx"
when 'debian','ubuntu'
  default['zend']['webuser'] = "www-data"
  default['zend']['webgroup'] = "www-data"
  default['zend']['apachepid'] = "apache2"
  default['zend']['apachedir'] = "/etc/apache2"
  default['zend']['phpdir'] = "/etc/php5"
  default['zend']['nginxdir'] = "/etc/nginx"
else
  raise 'Bailing out, unknown platform.'
end

# set zend info
default['zend']['zendsrc_url'] = "http://downloads.zend.com/guard"
default['zend']['zendfile'] = "zend-loader-php5.5-linux-x86_64.tar.gz"
default['zend']['zendversion'] = "7.0.0"
default['zend']['zenddir'] = "/usr/local/zend"

include_attribute 'zend::customize'
