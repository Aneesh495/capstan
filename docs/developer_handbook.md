# Capstan Developer Handbook and Engineering Guide

## 1. Overview and Core Philosophy

Capstan is engineered for extreme determinism, local-first autonomy, and hardware-enforced isolation. When authoring modules, custom types, or systemd profiles within the Capstan ecosystem, adhere to these fundamental engineering axioms:

1. **Strict Idempotency**: A resource evaluation must produce zero side effects if live system state already satisfies the target specification.
2. **Topological Invariant Order**: Relationships must be explicit. Use Puppet containment (`contain`) and chaining arrows (`->`) to enforce deterministic compilation.
3. **Hardware-Aware Design**: Code should leverage Facter facts to discover NUMA sockets, isolated CPU masks, and hugepage availability before issuing configuration changes.
4. **Crash-Safe Rollback**: Every state mutation must maintain an active journal entry in `/var/lib/capstan/staging/pending` prior to dispatch.

---

## 2. Puppet Module Development Standards

Capstan modules reside in `modules/` for core components and `site-modules/` for profiles and roles. Every module adheres to the standard layout:

```
modules/capstan_<name>/
  ├── manifests/
  │   ├── init.pp         # Primary class entrypoint with typed parameters
  │   └── params.pp       # Default parameter derivations
  ├── lib/
  │   ├── puppet/
  │   │   ├── type/       # Custom RAL resource types
  │   │   ├── provider/   # Operating system providers
  │   │   └── functions/  # Puppet 4/8 custom modern functions
  │   └── facter/         # Custom system facts
  ├── templates/          # EPP templates
  └── metadata.json       # Puppet module metadata
```

### 2.1 Custom Type Implementation

Custom types reside in `lib/puppet/type/<name>.rb`. Always provide explicit documentation, validate input types, and assign default values:

```ruby
# frozen_string_literal: true

Puppet::Type.newtype(:capstan_custom_resource) do
  @doc = 'Manages custom edge hardware abstraction.'
  ensurable

  newparam(:name, namevar: true) do
    desc 'Unique namevar identifier.'
  end

  newproperty(:parameter_name) do
    desc 'Descriptive property declaration.'
  end
end
```

### 2.2 Provider Architecture

Providers reside in `lib/puppet/provider/<type>/<provider>.rb`. Providers must implement:
- `exists?`: Fast check inspecting live state (sysfs, files, or CLI query)
- `create`: Dispatches mutation to reach target state
- `destroy`: Safely removes or unlinks the managed entity

---

## 3. Custom Facter Facts

Facts reside in `lib/facter/<name>.rb`. Always confine facts to relevant operating system families:

```ruby
# frozen_string_literal: true

require 'facter'

Facter.add(:capstan_hardware_feature) do
  confine kernel: 'Linux'
  setcode do
    # Probe hardware registers or /sys virtual filesystem
  end
end
```

---

## 4. Local Testing and Verification

Before committing changes, execute the root verification harness:

```bash
# Run all automated verification passes
./scripts/verify.sh

# Run Python unit tests
pytest tests -v

# Run Ruby RSpec tests
rspec spec/
```
