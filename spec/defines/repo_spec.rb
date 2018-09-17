require 'spec_helper'
describe 'rhsm::repo' do
  on_supported_os.each do |os, facts|
    context "on supported OS #{os} " do
      let(:facts) do
        facts.merge(
          'rhsm' => {
            'enabled_repo_ids' => []
          }
        )
      end

      context 'enabling server rpms' do
        let(:title) { 'rhel-7-server-rpms' }

        it { is_expected.to compile }

        it {
          is_expected.to contain_exec('RHSM-enable_rhel-7-server-rpms').with(
            command: 'subscription-manager repos --enable rhel-7-server-rpms'
          )
        }
      end

      context 'enabling optional rpms' do
        let(:title) { 'rhel-7-optional-rpms' }

        it { is_expected.to compile }

        it {
          is_expected.to contain_exec('RHSM-enable_rhel-7-optional-rpms').with(
            command: 'subscription-manager repos --enable rhel-7-optional-rpms'
          )
        }
      end

      context 'skipping already enabled repo' do
        let(:title) { 'rhel-7-optional-rpms' }

        let(:facts) do
          facts.merge(
            'rhsm' => {
              'enabled_repo_ids' => [
                'rhel-7-optional-rpms'
              ]
            }
          )
        end

        it { is_expected.to compile }

        it { is_expected.not_to contain_exec('RHSM-enable_rhel-7-optional-rpms') }
      end
    end
  end
end
