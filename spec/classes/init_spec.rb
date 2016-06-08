require 'spec_helper'
describe 'vodafone_java' do
  context 'with default values for all parameters' do
    it { should contain_class('vodafone_java') }
  end
end
