require 'spec_helper'

describe '::vodafone_java::jdk', type: :class do
  context 'calling with params for jdk class' do
    let(:params) do
      {
        instalationLocation: '/opt/SP/apps',
        version: '7',
        functionalUser: 'jboss'
      }
    end

    it { should contain_class('vodafone_java::jdk') }
    it { should create_class('vodafone_java::jdk') }
  end
end
