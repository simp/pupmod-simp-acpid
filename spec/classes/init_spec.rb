require 'spec_helper'

describe 'acpid' do
  it { should create_class('acpid') }

  it { should compile.with_all_deps }
  it { should create_package('acpid') }
  it { should create_service('acpid').that_requires('Package[acpid]') }
end
