require 'spec_helper'

describe 'acpid' do
  on_supported_os.each do |os, os_facts|
    # Only base OS facts are provided (no module-specific facts), so these
    # examples also prove the module compiles cleanly with nothing extra set.
    let(:facts) { os_facts }

    context "on #{os}" do
      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('acpid') }
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

      context 'with a non-default $ensure' do
        let(:params) { { ensure: 'latest' } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package('acpid').with(ensure: 'latest') }
      end

      # Exercises the actual SIMP business logic: with no parameter passed,
      # $ensure resolves via simplib::lookup('simp_options::package_ensure').
      # The hieradata fixture sets it to a value distinct from the default so a
      # pass proves the lookup path (not the default) supplied it.
      # See spec/fixtures/hieradata/package_ensure.yaml.
      context 'with simp_options::package_ensure set in hiera' do
        let(:hieradata) { 'package_ensure' }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package('acpid').with(ensure: '2.0.0') }
      end
    end
  end
end
