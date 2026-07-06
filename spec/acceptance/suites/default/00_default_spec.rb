require 'spec_helper_acceptance'

test_name 'acpid class'

describe 'acpid class' do
  let(:manifest) do
    <<-EOS
      include '::acpid'
    EOS
  end

  hosts.each do |host|
    context "on #{host}" do
      # Using puppet_apply as a helper
      it 'works with no errors' do
        apply_manifest(manifest, catch_failures: true)
      end

      it 'is idempotent' do
        apply_manifest(manifest, { catch_changes: true })
      end

      # With the module already applied (and no module-specific facts set), a
      # noop run must report no pending changes. This is the meaningful noop
      # assertion: it proves the module is idempotent under noop rather than
      # merely that the catalog compiles (which the real apply above covers).
      it 'reports no changes when run in noop mode after convergence' do
        apply_manifest(manifest, catch_changes: true, noop: true)
      end

      describe package('acpid') do
        it { is_expected.to be_installed }
      end

      describe service('acpid') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end
    end
  end
end
