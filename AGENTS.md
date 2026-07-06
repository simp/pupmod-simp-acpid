# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## What this module does

`pupmod-simp-acpid` is a SIMP Puppet module that manages the ACPI event daemon
(`acpid`) on Enterprise Linux systems. It is intentionally small: a single class
that installs the `acpid` package and keeps the `acpid` service enabled and
running.

### Business logic

All behavior lives in the one class, `acpid` (`manifests/init.pp`):

- **`$ensure`** (`String`, default `simplib::lookup('simp_options::package_ensure',
  { 'default_value' => 'installed' })`) — the package state for `acpid`. It follows
  the standard SIMP pattern of deferring to the site-wide `simp_options::package_ensure`
  hiera key when set, falling back to `installed` otherwise. Set it to e.g. `latest`
  to track updates.
- Declares `package { 'acpid': ensure => $ensure }`.
- Declares `service { 'acpid' }` as `ensure => running`, `enable => true`,
  `hasstatus`/`hasrestart => true`, and `require => Package['acpid']` — so the
  service is only managed after the package is present.

There are no other classes, defined types, facts, functions, or templates. The
module has no conditional OS logic in the manifest; OS coverage comes from
`metadata.json` (EL8–10 across RedHat/CentOS/Oracle/Rocky/Alma) and the acceptance
node sets.

**Known constraint (from `manifests/init.pp`):** `acpid` is *not* compatible with
GFS2 and must not be included alongside it — the two subsystems deliberately
conflict.

## Dependencies

- `simp/simplib` (`>= 4.9.0 < 6.0.0`) — provides `simplib::lookup`.
- `puppetlabs/stdlib` (`>= 8.0.0 < 10.0.0`).
- Runtime: `openvox >= 8.0.0 < 9.0.0` (see `metadata.json` `requirements`).

## Repository layout

- `manifests/init.pp` — the entire module (class `acpid`).
- `spec/classes/init_spec.rb` — rspec-puppet unit tests.
- `spec/acceptance/suites/default/` — beaker acceptance suite; `nodesets/` holds
  the per-OS Vagrant/libvirt node definitions.
- `REFERENCE.md` — generated Puppet Strings reference (do not hand-edit; regenerate).
- `metadata.json` — module metadata, dependencies, and supported OS matrix.

## Common commands

This module currently uses `puppetlabs_spec_helper` + `simp-rake-helpers (~> 5)`
+ `simp-beaker-helpers (~> 2)`; tasks come from `Simp::Rake::Pupmod::Helpers`
(see `Rakefile`).

```sh
bundle install

# Unit tests (rspec-puppet)
bundle exec rake spec

# Lint / style
bundle exec rake lint
bundle exec rake rubocop

# Regenerate REFERENCE.md after changing manifest docstrings
bundle exec puppet strings generate --format markdown --out REFERENCE.md

# Acceptance tests (beaker; needs a hypervisor — CI uses vagrant_libvirt)
bundle exec rake beaker:suites[default]
# or a specific node set:
bundle exec rake beaker:suites[default,el9]
```

Note `.rspec` sets `--fail-fast`, so `rake spec` stops at the first failure.

## Conventions

- This is a component of the SIMP ecosystem. Follow SIMP module conventions:
  parameters that reflect site-wide policy are resolved through
  `simp_options::*` hiera keys via `simplib::lookup`, defaulting to safe values
  so the module works standalone.
- Keep manifest parameter `@param` docstrings current — `REFERENCE.md` is
  generated from them.
