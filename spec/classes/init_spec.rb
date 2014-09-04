require 'spec_helper'
describe 'rhsm' do

  context 'with defaults for all parameters' do
    it { should contain_class('rhsm') }
  end
end
