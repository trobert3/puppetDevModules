require 'spec_helper'
describe 'sdp_multitailer' do
  context 'with default values for all parameters' do
    it { should contain_class('sdp_multitailer') }
  end
end
