require 'spec_helper'

describe 'acpid' do
  on_supported_os.each do |os, os_facts|
    let(:facts) { os_facts }

    context "on #{os}" do
      it { is_expected.to compile.with_all_deps }
      it { is_expected.to create_class('acpid') }

      context 'base' do
        it { is_expected.to contain_package('acpid').with(ensure: 'installed') }
        it { is_expected.to contain_service('acpid').that_requires('Package[acpid]') }
        it do
          is_expected.to contain_service('acpid')
            .with(
              ensure: 'running',
              enable: true,
              hasstatus: true,
              hasrestart: true,
            )
        end
      end
    end
  end
end
