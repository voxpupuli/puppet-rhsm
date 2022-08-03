# frozen_string_literal: true

require 'spec_helper'
describe 'rhsm', type: :class do
  on_supported_os.each do |os, facts|
    context "on supported OS #{os}" do
      let :facts do
        facts
      end

      context 'with defaults for all parameters' do
        it { is_expected.not_to compile }
      end

      context 'with provided password and username' do
        let :params do
          {
            rh_password: 'password',
            rh_user: 'username'
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package('subscription-manager') }
        it { is_expected.to contain_file('/etc/rhsm/rhsm.conf') }
        it { is_expected.not_to contain_file('/etc/yum.repos.d/redhat.repo') }
        it { is_expected.to contain_file('/etc/rhsm/rhsm.conf').with_content(%r{^package_profile_on_trans = 0$}) }

        it do
          is_expected.to contain_service('rhsmcertd').with(
            ensure: 'running', enable: 'true'
          )
        end

        it do
          is_expected.to contain_exec('RHSM-register').with(
            command: sensitive("subscription-manager register --name='#{facts[:fqdn]}' --username='username' --password='password'")
          )
        end

        if facts[:os]['family'] == 'RedHat' && facts[:os]['release']['major'] < '8'
          it do
            is_expected.to contain_file('/etc/yum/pluginconf.d/subscription-manager.conf').
              with_owner('root').
              with_group('root').
              with_mode('0644').
              with_content(%r{^\[main\]$}).
              with_content(%r{^enabled=1$})
          end
        else
          it do
            is_expected.to contain_file('/etc/dnf/plugins/subscription-manager.conf').
              with_owner('root').
              with_group('root').
              with_mode('0644').
              with_content(%r{^\[main\]$}).
              with_content(%r{^enabled=1$})
          end
        end
      end

      context 'with provided org and activation key' do
        let :params do
          {
            org: 'org',
            activationkey: 'key'
          }
        end

        it do
          is_expected.to contain_exec('RHSM-register').with(
            command: sensitive("subscription-manager register --name='#{facts[:fqdn]}' --org='org' --activationkey='key'")
          )
        end
      end

      context 'with list of repos to enable' do
        let(:params) do
          {
            rh_password: 'password',
            rh_user: 'username',
            enabled_repo_ids: [
              'rhel-7-server-rpms',
              'rhel-7-server-optional-rpms'
            ]
          }
        end

        it { is_expected.to have_rh_repo_resource_count(2) }

        it { is_expected.to contain_rh_repo('rhel-7-server-rpms') }
        it { is_expected.to contain_rh_repo('rhel-7-server-optional-rpms') }
      end

      context 'with proxy scheme set to https' do
        let(:params) do
          {
            org: 'org',
            activationkey: 'key',
            proxy_hostname: 'proxy.example.com',
            proxy_scheme: 'https',
            proxy_port: 443
          }
        end

        it do
          is_expected.to contain_exec('RHSM-register').with(
            command: sensitive("subscription-manager register --name='#{facts[:fqdn]}' --org='org' --activationkey='key' --proxy=https://proxy.example.com:443")
          )
        end

        it do
          is_expected.to contain_file('/etc/rhsm/rhsm.conf').with_content(%r{^proxy_scheme = https$})
        end
      end

      context 'with no_proxy set to proxy.local' do
        let(:params) do
          {
            org: 'org',
            activationkey: 'key',
            no_proxy: 'proxy.local'
          }
        end

        it do
          is_expected.to contain_file('/etc/rhsm/rhsm.conf').with_content(%r{^no_proxy = proxy.local$})
        end
      end

      context 'with specific plugin options' do
        let :params do
          {
            rh_password: 'password',
            rh_user: 'username',
            plugin_settings: { 'main' => { 'enabled' => 0, 'disable_system_repos' => 1 } }
          }
        end

        if facts[:os]['family'] == 'RedHat' && facts[:os]['release']['major'] < '8'
          # disable_system_repos doesn't actually do anything on EL6 or 7
          it do
            is_expected.to contain_file('/etc/yum/pluginconf.d/subscription-manager.conf').
              with_owner('root').
              with_group('root').
              with_mode('0644').
              with_content(%r{^\[main\]$}).
              with_content(%r{^enabled=0$}).
              with_content(%r{^disable_system_repos=1$})
          end
        else
          it do
            is_expected.to contain_file('/etc/dnf/plugins/subscription-manager.conf').
              with_owner('root').
              with_group('root').
              with_mode('0644').
              with_content(%r{^\[main\]$}).
              with_content(%r{^enabled=0$}).
              with_content(%r{^disable_system_repos=1$})
          end
        end
      end
    end
  end
end
