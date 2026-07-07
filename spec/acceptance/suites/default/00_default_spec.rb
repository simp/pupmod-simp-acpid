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
      # Exercise noop from a clean (uninstalled) state. Running noop *before*
      # the module is applied is the meaningful assertion: it proves the module
      # reports its intended changes without enacting them. (A noop run after
      # convergence only re-proves idempotence, which the real apply below
      # already covers.)
      context 'in noop mode from a clean state' do
        it 'removes the package so the run starts clean' do
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
          apply_manifest(manifest, { catch_changes: true })
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
