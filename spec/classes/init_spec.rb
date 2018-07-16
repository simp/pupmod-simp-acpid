require 'spec_helper'

describe 'acpid' do
  on_supported_os.each do |os, facts|
    let(:facts) do
      facts
    end

    context "on #{os}" do
      it { is_expected.to compile.with_all_deps }
      it { is_expected.to create_class('acpid') }

      context 'base' do
        it { is_expected.to contain_package('acpid').with( :ensure => 'installed')}
        it { is_expected.to contain_service('acpid').that_requires('Package[acpid]') }
        it { is_expected.to contain_service('acpid').with({
          :ensure     => 'running',
          :enable     => true,
          :hasstatus  => true,
          :hasrestart => true,
          :start      => '/sbin/service haldaemon stop; /sbin/service acpid start; /sbin/service haldaemon start',
          })
        }
      end
    end
  end
end
