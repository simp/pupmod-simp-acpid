require 'spec_helper'

describe 'acpid' do
  it { is_expected.to create_class('acpid') }

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to create_package('acpid') }
  it { is_expected.to create_service('acpid').that_requires('Package[acpid]') }
end
