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
      # Exercise noop behavior and noop idempotency:
      # - From a clean state, noop should report intended changes without enacting them.
      # - After a real apply, a noop run with `catch_changes: true` should report no pending changes.
      # This guards against resources that behave differently under noop.
      #
      context 'in noop mode from a clean state' do
        it 'removes the package so the run starts clean' do
          on(host, 'puppet resource package acpid ensure=absent', acceptable_exit_codes: [0, 2])
        end

        it 'applies without errors in noop mode' do
          apply_manifest(manifest, catch_failures: true, noop: true)
        end

        describe package('acpid') do
          it 'is not installed by the noop run' do
            is_expected.not_to be_installed
          end
        end
      end

      context 'when applied' do
        # Using puppet_apply as a helper
        it 'works with no errors' do
          apply_manifest(manifest, catch_failures: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end

        it 'has no pending changes in noop mode' do
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
end
