require 'spec_helper'

describe 'vodafone_java' do

    context 'with Solaris default values' do
        let(:facts) { {:os => { :family => 'Solaris', :release => { :major => '10' } } } }

        it { should contain_class('vodafone_java') }
        it { should create_class('vodafone_java::jdk') }
    end

    context 'with RedHat default values' do
        let(:facts) { {:os => { :family => 'RedHat', :release => { :major => '7', :minor => '1', :full => '7.1.1503' } } } }

        it { should contain_class('vodafone_java') }
        it { should create_class('vodafone_java::jdk') }
    end
end
