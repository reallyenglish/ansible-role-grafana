require "spec_helper"
require "serverspec"

grafana_package_name = "grafana"
grafana_service_name = "grafana"
grafana_config       = "/etc/grafana/grafana.ini"
# grafana_user         = "grafana"
# grafana_group        = "grafana"
grafana_data         = "/var/db/grafana2"
grafana_logs         = "/var/log/grafana2"

case os[:family]
when "freebsd"
  grafana_package_name = "grafana2"
  grafana_service_name = "grafana2"
  grafana_config       = "/usr/local/etc/grafana2.conf"
  grafana_root         = "/usr/local/share/grafana"
end

describe package(grafana_package_name) do
  it { should be_installed }
end

describe file(grafana_root) do
  it { should be_directory }
  it { should be_mode 755 }
end

[grafana_data, grafana_logs, grafana_root].each do |d|
  describe file(d) do
    it { should be_directory }
    it { should be_mode 755 }
  end
end

describe file(grafana_config) do
  it { should be_file }
  its(:content) { should match Regexp.escape "data = #{grafana_data}" }
  its(:content) { should match Regexp.escape "logs = #{grafana_logs}" }
  its(:content) { should match(/http_port = 3000/) }
  its(:content) { should match(/admin_user = root/) }
  its(:content) { should match(/admin_password = password/) }
end

describe service(grafana_service_name) do
  it { should be_running }
  it { should be_enabled }
end

describe port(3000) do
  it { should be_listening }
end
