require 'spec_helper'

describe '::vodafone_java::jdk', type: :class do
    context 'calling with params for jdk class' do
        let(:params) { { :instalationLocation => '/opt/SP/apps', :version => '7', :functionalUser => 'jboss' } }

        it { should contain_class('vodafone_java::jdk') }
        it { should create_class('vodafone_java::jdk') }
    end
end

