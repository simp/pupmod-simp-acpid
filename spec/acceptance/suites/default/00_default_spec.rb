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
      # Exercise noop from a clean (uninstalled) state: a noop apply should
      # report the module's intended changes without enacting them, so the
      # package must remain absent afterward. Real idempotence is covered by
      # the apply below. A *post-convergence* noop check is deliberately
      # omitted: `puppet apply --noop --detailed-exitcodes` always exits 0
      # regardless of pending changes, so a catch_changes+noop assertion can
      # never fail and would test nothing.
      context 'in noop mode from a clean state' do
        # Setup, not an assertion: a failure here should error the context
        # rather than abort the suite under --fail-fast. `puppet resource`
        # exits 0 whether it removes the package or finds it already absent
        # (it does not use --detailed-exitcodes), so no acceptable_exit_codes
        # override is needed.
        before(:context) do
          on(host, 'puppet resource package acpid ensure=absent')
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
