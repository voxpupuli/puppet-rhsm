require 'spec_helper'
describe 'rhsm', type: :class do
  on_supported_os.each do |os, facts|
    context "on supported OS #{os} " do
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
        it { should compile.with_all_deps }
        it { should contain_package('subscription-manager') }
        it { should contain_file('/etc/rhsm/rhsm.conf') }
        it { should contain_exec('sm yum clean all') }
        it { should contain_exec('RHNSM-register') }
      end
    end
  end
end
