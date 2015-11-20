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
#

# install zend from source
zend_src_url = "#{node['zend']['zendsrc_url']}/#{node['zend']['zendversion']}/#{node['zend']['zendfile']}"

# download the file
remote_file "/tmp/#{node['zend']['zendfile']}" do
  source zend_src_url
  mode 0644
  action :create_if_missing
  ignore_failure true
  not_if "test -f /tmp/#{node['zend']['zendfile']}"
end

# untar it
execute "tar --no-same-owner -zxvf #{node['zend']['zendfile']}" do
  cwd "/tmp"
end

# create default zend directory
directory "#{node['zend']['zenddir']}" do
  mode 0755
  action :create
  not_if { ::Dir.exists?("#{node['zend']['zenddir']}") }
end

# move zend files to proper directory
execute "zend install" do
  environment({"PATH" => "/usr/local/bin:/usr/bin:/bin:$PATH"})
  command "mv /tmp/zend-loader-*/ZendGuardLoader.so #{node['zend']['zenddir']}/zendguard_loader_#{node['zend']['zendversion']}.so && mv /tmp/zend-loader-*/opcache.so #{node['zend']['zenddir']}/zendguard_opcache_#{node['zend']['zendversion']}.so"
  ignore_failure true
end

# disable preinstalled opcache due to module conflicts
if platform?('debian', 'ubuntu')
  execute "zend opcache disable" do
    environment({"PATH" => "/usr/local/bin:/usr/bin:/bin:$PATH"})
    command "/usr/sbin/php5dismod opcache"
    ignore_failure true
    only_if { ::File.exists?("/usr/lib/php5/20121212/opcache.so") }
    only_if { ::File.exists?("/usr/sbin/php5enmod") }
  end
end

# symlink zend version to php directory
if platform?('debian', 'ubuntu')
  link "/usr/lib/php5/20121212/zend_loader.so" do
    to "#{node['zend']['zenddir']}/zendguard_loader_#{node['zend']['zendversion']}.so"
    ignore_failure true
    only_if { ::Dir.exists?("/usr/lib/php5") }
  end
  link "/usr/lib/php5/20121212/zend_opcache.so" do
    to "#{node['zend']['zenddir']}/zendguard_opcache_#{node['zend']['zendversion']}.so"
    ignore_failure true
    only_if { ::Dir.exists?("/usr/lib/php5") }
  end
end

# install zend module loader
if platform?('debian', 'ubuntu')
  template "#{node[:zend][:phpdir]}/mods-available/zend.ini" do
    source 'zend.ini.erb'
    ignore_failure true
    only_if { ::Dir.exists?("#{node[:zend][:phpdir]}") }
  end

  # do we manually symlink or use php5enmod ?
  if ::File.exists?("/usr/sbin/php5enmod")
    # enable zend php module
    # todo: add notify delay here so that it calls execute after everything else
    execute "zend php module enable" do
      environment({"PATH" => "/usr/local/bin:/usr/bin:/bin:/usr/sbin:$PATH"})
      command "/usr/sbin/php5enmod zend"
      ignore_failure true
      only_if { ::File.exists?("#{node[:zend][:phpdir]}/mods-available/zend.ini") }
    end
  else
    # symlink manually
    %w(apache2 cli fpm).each do |process|
      link "#{node[:zend][:phpdir]}/#{process}/conf.d/zend.ini" do
        to "#{node[:zend][:phpdir]}/mods-available/zend.ini"
        ignore_failure true
        only_if { ::Dir.exists?("#{node[:zend][:phpdir]}/#{process}") }
      end
    end
  end

# todo: redhat/amazon install ref
end

# clean up install path
execute "zend cleanup" do
  environment({"PATH" => "/usr/local/bin:/usr/bin:/bin:$PATH"})
  command "rm -rf /tmp/zend*"
  cwd "/tmp"
  ignore_failure true
end
