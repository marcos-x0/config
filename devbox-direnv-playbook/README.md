# Devbox + Direnv Playbook

This document is written for an LLM assistant that will apply this system to a real
project structure.

[Devbox](https://www.jetify.com/devbox) creates isolated, reproducible development
environments using Nix. It pins exact tool versions per directory — a project can
declare `nodejs@18` and get exactly that, regardless of what is installed on the host
system.

[direnv](https://direnv.net) is an environment switcher for the shell. It hooks into
your shell and automatically loads or unloads environment variables and tooling when
you `cd` into or out of a directory. No manual activation, no remembering to switch
contexts.

Together, they form a system where each project directory gets its own isolated
toolchain, activated automatically on entry and cleanly removed on exit. This playbook
describes how to set up and layer these two tools for a multi-project workspace with
correct version priority and full environment isolation.

The system is language-agnostic. The examples use Node.js, but the same architecture
applies to any language ecosystem — Python, Rust, Scala, OCaml, Go, or any combination.
Applying this playbook to a specific language requires understanding that language's
runtime, package manager, and global install mechanisms. Creativity and adaptability
are expected from the implementing LLM.

## The Problem

You have a directory on your machine that contains multiple independent projects.
These projects have conflicting requirements: different versions of the same runtime,
different runtimes and languages entirely, different package managers (or different
major versions of the same one), and different sets of globally installed tools. Even
two projects that share the same runtime version may need completely different global
tooling. The operating system provides one shared environment — but projects need
complete isolation of runtime, package manager, global tools, everything. Each project
should behave as if it is the only one on the machine.

The subsections below use Node.js as the running example, but every language ecosystem
has the same shape. A runtime, a package manager, and a global install location where
tools and binaries end up when installed system-wide. All assets a language's toolchain
produces — globally installed binaries, cached artifacts, build outputs — must be scoped
to the project that created them. When they are not, projects bleed into each other.
This applies equally to Python, Rust, Scala, OCaml, or any other language. The specifics
differ but the problem is identical. The LLM applying this playbook must understand the
target language's ecosystem well enough to map these concepts creatively — identifying
what needs to be isolated and how to scope it per project.

Node.js is a particularly hard case. The ecosystem has multiple competing package
managers — npm, pnpm, and yarn — each with different lockfile formats, different
storage strategies, and different global install locations. Running yarn in a project
that uses npm creates a `yarn.lock` alongside `package-lock.json` and corrupts the
dependency tree. Yarn v1 and yarn v4 are fundamentally different tools that happen to
share a name. And `npm install -g` writes binaries to a single system-wide directory —
if two projects install different versions of the same CLI tool globally, the last one
wins and the other project breaks silently. Every one of these must be scoped per
project for true isolation.

### Version Conflicts Across Projects

Different projects require different versions of the same runtime. The system has one
binary on PATH — whichever version was activated last wins, and the other project
silently runs against the wrong one. The resulting errors often point nowhere near the
actual cause. Version managers exist but only solve the runtime problem, not the full
toolchain problem — two projects may share the same runtime version yet require
incompatible tooling around it.

In Node.js, one repo may need version 18 while another needs 24. Tools like nvm can
switch between them, but if both repos use Node.js 24 and one needs yarn v1 while the
other needs yarn v4, nvm cannot help. Every language ecosystem has its own variant of
this — different projects sharing a runtime version but needing incompatible tooling
around it.

### Global Package Contamination

Package managers have a system-wide location for globally installed tools. When two
projects install different versions of the same tool globally, the last one wins and
the other breaks silently. Even projects that share the same runtime version may need
completely different global tools, or different versions of the same tool. There is no
per-project boundary for global installs by default.

In Node.js, `npm install -g typescript@5.0` in repo A and `npm install -g typescript@5.6`
in repo B write to the same directory — the second overwrites the first. Any language
where a package manager places binaries in a shared location has this same problem.

### Package Manager Cross-Contamination

Projects using the same runtime may use different package managers — or different major
versions of the same one. Running the wrong package manager in a project creates wrong
lockfiles, wrong directory structures, and errors. Some package managers are
fundamentally incompatible tools that happen to share a binary name, making isolation
essential.

In Node.js, repo A uses npm, repo B uses yarn v1, repo C uses yarn v4. Yarn v1 and
yarn v4 are incompatible — you cannot have both available for the same Node.js version
without isolation. pnpm has its own store strategy that conflicts with both. Any
language ecosystem with competing package managers or incompatible major versions of
the same one faces this problem.

### Nested Devbox Activation and PATH Priority

Devbox solves version pinning per directory — each project declares its own runtime and
tools. But when a parent directory has a `devbox.json` and a child directory also has
one, both activate. By default the activation order produces wrong PATH priority — the
parent's devbox paths can end up before the child's, shadowing the child's tools with
the parent's versions.

This is the core technical challenge this playbook solves. Multiple devbox environments
must be layered simultaneously with correct priority — the innermost project's tools
always win, then the parent's, then the grandparent's, up to `<project-root>`. Getting
this wrong means a project silently uses the wrong version of a tool it explicitly
declared.

## The Solution: Architecture Overview

Devbox and direnv solve these problems together. A `<project-root>` directory contains
all projects. Each project declares its own toolchain via `devbox.json`, and direnv
activates it automatically on `cd`. The system supports N-layer devbox — multiple
devbox environments layered simultaneously with correct PATH priority — though in
practice 2-3 layers is the realistic maximum. When you switch from one project to
another, direnv fully unloads the previous environment and loads the new one from
scratch. No state carries over between projects.

The PATH is ordered so that the innermost project's devbox bin directories come first.
Then the parent's devbox bin directories, then the grandparent's, and so on until
reaching `<project-root>`'s devbox bin directories. Below all of those sit homebrew bin,
then devbox global bin, then `~/.local/bin`, then the default OS bin directories. This
means a project declaring `nodejs@18` will always resolve to that version, even if a
parent has `nodejs@24` and devbox global has `nodejs@26`. The following subsections
detail how this layering is implemented.

### Directory Structure

A `<project-root>` directory sits at the top. It contains the bootstrap `.envrc`, the
shared `.envrc.default`, and optionally a `devbox.json` for tools shared across all
projects. Each project lives in a subdirectory with its own `devbox.json` and a
`.envrc` symlink pointing to `../.envrc.default`. Monorepos nest further — packages
inside a monorepo can have their own `devbox.json` and `.envrc` symlink.

The `.devbox/` directory in each project holds devbox's nix environment and is the
home for all project-scoped assets that need isolation. Anything a language's toolchain
would normally place in a shared system location belongs here instead. For Node.js,
`npm install -g` binaries go in `.devbox/npm-global/bin`. For Rust, `cargo install`
binaries and build artifacts would go under `.devbox/cargo/`. The pattern is the same
for any language — redirect global outputs into `.devbox/` so they are scoped to the
project. Ensure `.devbox/` is in `.gitignore`.

While this playbook uses Node.js as the example, it is not uncommon for a single
project to use Node.js, Python, and Rust together. Each language's global assets must
be properly organized within `.devbox/` following the patterns that language's ecosystem
expects — `.devbox/npm-global/` for Node.js, `.devbox/cargo/` for Rust, and so on.
Without this discipline, `.devbox/` becomes a disorganized dump — and a disorganized
project-local directory defeats the entire purpose of isolating things from a
disorganized system-level one.

```
<project-root>/
├── .envrc                            # Standalone bootstrap (NOT a symlink)
├── .envrc.default                    # Shared engine (all projects symlink to this)
├── devbox.json                       # Optional shared tools
├── .devbox/                          # Root devbox nix environment + shared assets
│
├── api-service/                      # Flat repo — nodejs@24, npm
│   ├── .envrc -> ../.envrc.default
│   ├── devbox.json
│   ├── .envrc.local
│   ├── .env.local
│   └── .devbox/
│       └── npm-global/bin/
│
├── auth-service/                     # Flat repo — nodejs@18, yarn v1
│   ├── .envrc -> ../.envrc.default
│   ├── devbox.json
│   └── .devbox/
│       └── npm-global/bin/
│
├── worker/                           # Flat repo — nodejs@24, pnpm
│   ├── .envrc -> ../.envrc.default
│   ├── devbox.json
│   └── .devbox/
│       └── npm-global/bin/
│
├── platform/                         # Monorepo — nodejs@24, yarn v4
│   ├── .envrc -> ../.envrc.default
│   ├── devbox.json
│   ├── packages/
│   │   ├── ui/
│   │   │   ├── .envrc -> ../../../.envrc.default
│   │   │   ├── devbox.json           # Adds package-specific tools
│   │   │   └── .devbox/
│   │   │       └── npm-global/bin/
│   │   └── shared/
│   │       ├── .envrc -> ../../../.envrc.default
│   │       └── ...                   # No devbox.json, inherits from platform
│   └── .devbox/
│       └── npm-global/bin/
│
└── data-pipeline/                    # Monorepo — nodejs@18, npm
    ├── .envrc -> ../.envrc.default
    ├── devbox.json
    ├── ingest/
    │   ├── .envrc -> ../../.envrc.default
    │   ├── devbox.json
    │   └── .devbox/
    │       └── npm-global/bin/
    ├── transform/
    │   ├── .envrc -> ../../.envrc.default
    │   └── ...                       # No devbox.json, inherits from data-pipeline
    └── .devbox/
        └── npm-global/bin/
```

### PATH Priority Order

Using `platform/packages/ui/` as the example — a package inside a monorepo:

```
<project-root>/
└── platform/                         # devbox.json — nodejs@24, yarn v4
    └── packages/
        └── ui/                       # devbox.json — adds storybook tooling
            └── you are here
```

When inside `platform/packages/ui/`, PATH is ordered from highest to lowest priority:

```
<project-root>/platform/packages/ui/.devbox/npm-global/bin    # ui's global package binaries
<project-root>/platform/packages/ui/.devbox/nix/profile/default/bin  # ui's devbox tools
<project-root>/platform/.devbox/nix/profile/default/bin       # platform's devbox tools
<project-root>/.devbox/nix/profile/default/bin                # shared tools
/opt/homebrew/bin                                             # homebrew
~/.local/share/devbox/global/default/.nix-profile/bin         # devbox global
~/.local/bin                                                  # personal tools
/usr/local/bin                                                # system local
/usr/bin                                                      # macOS system
/bin                                                          # macOS core
```

The innermost project always wins. If `ui/` declares a tool that `platform/` also has,
`ui/`'s version takes priority. Homebrew sits above devbox global intentionally — it
serves as a fast override when a devbox package is outdated and waiting for a nix
update.

### What This System Manages vs What It Does Not

**This system manages:**
- Devbox activation per directory (when a `devbox.json` exists in the directory)
- PATH priority across N devbox layers
- Project-scoped global package isolation via `.devbox/`
- Environment variable loading (`.env.local`, `.envrc.local`)
- Automatic activation and clean deactivation on `cd`

**This system does NOT manage, but depends on:**
- Shell init files (`.zshenv`, `.zshrc`) — homebrew shellenv, devbox global shellenv,
  and the direnv hook must be configured at the top of these files before this system
  works. Without them, direnv never triggers and devbox global is not on PATH.
- Devbox global — installed separately, always on PATH, provides fallback tools
- Homebrew — installed separately, always on PATH, provides fast overrides

**Outside scope entirely:**
- `~/.envrc` — personal direnv configuration, not managed by this system
- `~/.local/bin` — personal tools, managed manually

## The Files

The system is built from a small set of files, each with one job. A standalone bootstrap
file at `<project-root>` activates all devbox environments in the correct order. A shared
engine file contains all the common logic — devbox directory recording, environment
loading, and the upward chain — and every project symlinks to it instead of duplicating
it. Per-project customization files handle anything specific to a single project. The
subsections below explain each file, what it does, and why.

### <project-root>/.envrc — The Bootstrap

This is a standalone file — NOT a symlink to `.envrc.default`. It is the only `.envrc`
in the system that is its own file. It has three jobs:

1. Receive `DEVBOX_DIRS` from the child chain — the list of directories with
   `devbox.json` that need activation
2. Activate all devbox environments in order — `<project-root>` first, then
   shallowest child to deepest, so the innermost project's tools end up at the
   front of PATH
3. Call `source_env_if_exists` to load any `.envrc` files further up the directory
   tree (such as `~/.envrc` for personal configuration). This runs before any
   project-specific configuration below it, so variables defined after it in the
   current file take precedence.

This file is the final stop in the direnv chain walking upward. Every `.envrc.default`
eventually reaches here through `source_up_if_exists`. By the time execution arrives,
`DEVBOX_DIRS` contains the full list of directories that need devbox activation — but
none have been activated yet. The bootstrap activates them all in the correct order.

### <project-root>/.envrc.default — The Shared Engine

Every `.envrc` below `<project-root>` is a symlink to this file. It contains all the
shared logic — devbox directory recording, environment loading, and the
`source_up_if_exists` chain that walks up to the bootstrap. The same code runs at every
level, regardless of nesting depth. Changes to this file apply instantly to all projects
through the symlinks.

#### Devbox Recording and the Upward Chain

When a project's `.envrc` runs (which is a symlink to `.envrc.default`), it checks if
`devbox.json` exists in the current directory.
If it does, it computes `ENVRC_DIR` — the actual directory containing the `.envrc` file,
resolved via `BASH_SOURCE[0]`, not `$PWD`. This matters because `$PWD` is wherever the
user cd'd into, which may not be the same as the directory containing the `.envrc`
symlink and its `devbox.json`. The resolved `ENVRC_DIR` is prepended to `DEVBOX_DIRS`.

If no `devbox.json` exists, the directory is not added to `DEVBOX_DIRS` — but it still
participates in direnv. Its `.env.local` and `.envrc.local` are loaded later, after the
upward chain completes (see Variable Precedence below).

After recording, `source_up_if_exists` chains to the parent directory's `.envrc`. The
parent runs the same `.envrc.default` logic — checks for `devbox.json`, prepends to
`DEVBOX_DIRS` if found, then chains to its parent. Because each level prepends, the list
builds in shallowest-to-deepest order. When the chain reaches `<project-root>/.envrc`,
`DEVBOX_DIRS` contains every directory that needs devbox activation, in the exact order
the bootstrap should activate them.

#### Variable Precedence and source_up_if_exists Placement

The placement of `source_up_if_exists` in `.envrc.default` is deliberate. It sits between
the devbox recording block (above) and the environment file loading block (below).
Everything above it runs before the parent chain executes. Everything below it runs after
the parent chain returns.

This means the current directory's `.env.local` and `.envrc.local` load after all parent
directories have loaded theirs. Inner directories overwrite outer directories. If a parent
sets `NODE_ENV=production` and a child sets `NODE_ENV=test`, the child wins. If a parent
adds a directory to PATH via `.envrc.local` and a child adds a different one, the child's
addition takes priority because it was added last.

This ordering is what makes the environment hierarchical — each level inherits from its
parents and can selectively override what it needs to.

#### Package Isolation via .devbox/

Every language ecosystem has a global install location that pollutes a shared system
directory by default. This system redirects those installs into `.devbox/` so they are
scoped to the project. For Node.js, set `NPM_CONFIG_PREFIX="$PWD/.devbox/npm-global"`
and add `PATH_add "$PWD/.devbox/npm-global/bin"` so globally installed binaries are
found. For other languages, the equivalent environment variable or configuration
redirects the global location into `.devbox/` following the same pattern.

The `PATH_add` for the global bin directory must come after `source_up_if_exists`.
Because `PATH_add` prepends to PATH, placing it after the upward chain ensures the
project's global bin directory ends up in front of everything the parent chain added —
including all devbox environments activated by the bootstrap and any parent directory's
own `PATH_add` calls. If a parent and child both add a global bin directory, the
innermost project's directory ends up first on PATH. Two versions of the same globally
installed tool resolve to the innermost project's version.

The safest place for `PATH_add` calls is `.envrc.local` — it is guaranteed to run after
`source_up_if_exists` at the correct point in the loading order. Whether the npm prefix
redirect belongs in `.envrc.default` (universal, all projects get it) or in each
project's `.envrc.local` (per-project, only where needed) depends on the workspace. If
every project is Node.js, put it in `.envrc.default`. If projects use different
languages, put language-specific redirects in each project's `.envrc.local`.

The `.devbox/` directory must be added to `.gitignore` — devbox does not do this
automatically. Once gitignored, everything placed inside it is excluded from version
control.

#### Per-Directory Configuration

After `source_up_if_exists` returns and the parent chain has fully executed,
`.envrc.default` loads two files from the current directory:

1. `.env.local` — loaded via `dotenv_if_exists`. Committed to git. Contains non-sensitive
   configuration and placeholder values for secrets (e.g.,
   `DB_PASSWORD=<add your dev password here>`).

2. `.envrc.local` — loaded via `source`. Committed to git. Contains bash scripts for
   per-project customization: `PATH_add` calls, tool configuration, package manager
   prefix redirects. **No environment variables here** — use `.env.local` for those.

`.env` files are **never loaded**. Sensitive data must not enter the shell environment
through direnv. Applications that need secrets should read `.env` files directly at
runtime.

### The Project Boundary

A boundary is created by the files present in a directory. An `.envrc` symlink (pointing
to `<project-root>/.envrc.default`) alone creates an environment variable boundary —
the directory participates in direnv, loads `.env.local` and `.envrc.local`, and inner
values override outer ones. Adding a `devbox.json` alongside the `.envrc` creates a
binary boundary — the directory gets its own isolated toolchain with pinned runtime and
package manager versions. Both files must be in the same directory for the full boundary
to exist.

Adding package isolation via `.devbox/` (configured in `.envrc.local`) completes the
picture with a global binary boundary — globally installed tools like `npm install -g`
binaries are scoped to the project instead of a shared system location. The three layers
stack: `.envrc` for environment variables, `devbox.json` for toolchain binaries, and
`.devbox/` for global package binaries.

#### <project-root>/devbox.json — Shared Tools

Optional. Created with `devbox init`, then populated with `devbox add`. Contains tools
that should be available across all projects — linters, formatters, common CLIs. These
are the lowest priority among devbox layers. Any project can override them by declaring
the same tool in its own `devbox.json`.

#### project-N/.envrc — The Symlink

Always a symlink to `<project-root>/.envrc.default`: `ln -s ../.envrc.default .envrc`
(or the appropriate relative path for deeper nesting). Never a standalone file — all
logic lives in `.envrc.default`. This file must exist for direnv to activate the
directory. Without it, direnv skips the directory entirely.

#### project-N/devbox.json — Project-Specific Tools

Created with `devbox init`, then populated with `devbox add`. Declares the project's
runtime version, package manager, and any project-specific tools. Versions are pinned
via the accompanying `devbox.lock`. This is what makes each project isolated — two
projects can declare different Node.js versions and both get exactly what they asked for.

#### project-N/.envrc.local — Per-Project Customization

Bash scripts only — no environment variables. This is where per-project customization
goes: `PATH_add` for tool bin directories, `NPM_CONFIG_PREFIX` redirects, commit ticket
prefix configuration, or any other bash setup unique to this project. Loaded last in the
per-directory sequence, so it can extend or override what `.envrc.default` set up.

#### project-N/.env.local — Committed Configuration

Committed to git. Contains non-sensitive configuration and placeholder values for
secrets. Examples: `NODE_ENV=development`, `API_URL=http://localhost:3000`,
`DB_PASSWORD=<add your dev password here>`. Loaded via `dotenv_if_exists` so variables
are available in the shell environment.

## The Activation Flow

This section walks through what actually happens when direnv triggers — the exact
sequence of file execution, devbox activation, PATH manipulation, and environment
loading. The files described above work together through direnv's `source_up_if_exists`
chain. The subsections show the step-by-step flow for entering a project, switching
between projects, and returning to `<project-root>`.

### Entering a Project: cd <project-root>/platform/packages/ui/

Using the 3-layer monorepo case for the fullest example:

1. Direnv finds `ui/.envrc` (symlink to `<project-root>/.envrc.default`)
2. `.envrc.default` runs in `ui/` — `devbox.json` exists, computes `ENVRC_DIR`,
   prepends to `DEVBOX_DIRS` → `DEVBOX_DIRS="ui_path"`
3. `source_up_if_exists` — `packages/` has no `.envrc`, skipped. Reaches
   `platform/.envrc` (symlink to `.envrc.default`)
4. `.envrc.default` runs in `platform/` — `devbox.json` exists, prepends →
   `DEVBOX_DIRS="platform_path:ui_path"`
5. `source_up_if_exists` — reaches `<project-root>/.envrc` (the bootstrap)
6. Bootstrap prepends root → `DEVBOX_DIRS="root_path:platform_path:ui_path"`
7. Bootstrap loops forward:
   - `eval --config root_path` → root devbox paths on PATH
   - `eval --config platform_path` → platform paths prepend (now in front of root)
   - `eval --config ui_path` → ui paths prepend (now in front of everything)
8. Bootstrap calls `source_env_if_exists ~/.envrc` — personal config loads
9. Execution returns down the chain. `platform/` loads its `.env.local` and
   `.envrc.local`. Then `ui/` loads its `.env.local` and `.envrc.local` — innermost
   values override.

Result: ui's tools on top of PATH, ui's env vars override platform's, platform's
override root's.

### Switching Projects: cd ../project-beta/

Direnv fully unloads the previous environment — every PATH addition, every environment
variable, every devbox activation from `platform/packages/ui/` is removed. The shell
returns to its state before entering that directory.

Then the entire activation flow starts fresh for `project-beta/`. `DEVBOX_DIRS` is
rebuilt from scratch. New devbox environments activate. New `.env.local` and `.envrc.local`
files load. No state from the previous project carries over. This is direnv's built-in
behavior — it restores the shell to its pre-entry state before loading the new directory.

### Returning to <project-root>/

When you `cd` back to `<project-root>/`, direnv unloads the previous project and loads
`<project-root>/.envrc`. No child `.envrc.default` ran, so `DEVBOX_DIRS` is empty. The
bootstrap prepends root and loops — only root's devbox activates. Root's `.env.local`
and `.envrc.local` load if they exist. This is the simplest case — a single devbox layer
with no children.

## Environment File Conventions

The system separates concerns across file types: devbox configuration, committed
environment variables with placeholder values, and per-project bash scripts for PATH
and tooling customization. Each file type has a defined role and a clear git status.
Sensitive information must never be loaded into the shell environment by direnv,
regardless of its origin — **especially never load `.env` files**. Secrets loaded into
the shell are visible in `env`, process listings, shell history, and every child
process. The loading order matters: files load from `<project-root>` down to the
current directory, and inner directories override outer ones for the same variable.

### File Types and Git Status

| File | Purpose | Git Status |
|------|---------|------------|
| `.envrc` | Symlink to `<project-root>/.envrc.default` | Committed |
| `.envrc.default` | Shared activation engine | Committed |
| `.envrc.local` | Bash scripts — PATH manipulation, tool config | Committed |
| `.env.local` | Non-sensitive config, placeholder values for secrets | Committed |
| `.env` | Real secrets — **never loaded by direnv** | Gitignored |
| `devbox.json` | Declares packages to install via nix | Committed |
| `devbox.lock` | Pinned nix package versions | Committed |
| `.devbox/` | Nix environment + isolated project assets | Must be gitignored |

### Loading Order Per Directory Level

Each directory that has an `.envrc` symlink loads its files in this order:

1. `.env.local` — committed configuration with placeholders
2. `.envrc.local` — bash scripts for PATH and tool customization

The loading happens from `<project-root>` down to the current directory. Each level
loads after its parent, so inner directories override outer ones for the same variable
or PATH entry.

```
<project-root>/.env.local → <project-root>/.envrc.local
    platform/.env.local → platform/.envrc.local
        platform/packages/ui/.env.local → platform/packages/ui/.envrc.local
```

A variable set in `ui/.env.local` overwrites the same variable set in
`platform/.env.local`. A `PATH_add` in `ui/.envrc.local` prepends in front of anything
`platform/.envrc.local` added.

### What Goes Where

- **Environment variables** → `.env.local`. If it's a key-value pair, it belongs here.
- **PATH manipulation, tool config, prefix redirects** → `.envrc.local`. If it's a bash
  script or a `PATH_add` call, it belongs here.
- **Secrets** → `.env`. Never loaded by direnv. The application reads this file directly
  at runtime.
- **Package declarations** → `devbox.json`. The runtime, package manager, and tools that
  devbox installs via nix.

## Performance and Control

Each devbox activation has a cost — direnv runs `devbox generate direnv` which invokes
Nix to resolve packages. More layers of devbox means a slower `cd` into that directory.
You control this cost by choosing which files exist in each directory. There are three
levers: remove the `.envrc` symlink, remove `devbox.json`, or remove both. Each trades
a different amount of functionality for speed.

Devbox is the heaviest part of the system. The first time you `cd` into a directory with
a `devbox.json`, devbox downloads and installs all declared packages from the nix store.
The terminal may appear unresponsive for several minutes while this happens. Subsequent
activations are fast because packages are cached. Patience on first load — it only
happens once per package set.

### Removing .envrc — Skip Direnv Entirely

Without an `.envrc` symlink, direnv does not activate the directory at all. No
environment variables load, no devbox recording happens, no `.envrc.local` runs. The
directory is invisible to the direnv chain — `source_up_if_exists` skips it when walking
upward. The directory can still contain a `devbox.json` and be activated manually with
`devbox shell`, but it will not participate in the automatic system.

### Removing devbox.json — Direnv Without Devbox

The directory still participates in direnv — its `.env.local` and `.envrc.local` load,
and the `source_up_if_exists` chain passes through it. But no devbox environment is
recorded for activation. This is useful for directories that only need environment
variables or PATH customization without their own toolchain — like a `packages/shared/`
directory in a monorepo that inherits its parent's devbox tools.

### Removing Both — Invisible to the System

The directory has no interaction with this system. Direnv skips it, devbox ignores it.
Zero overhead on `cd`. This is the default state of any directory that hasn't been set
up — you opt in by adding files, not opt out by removing them.

## Worked Example

The following subsections walk through a concrete `<project-root>` with five repos.
Three are single-project repos and two are monorepos with nested packages. This covers
the realistic range — flat projects, monorepos with shared tooling, and mixed nesting
depths — all coexisting under one `<project-root>` with full isolation.

### The Five Repos

Using the same structure from the Directory Structure section:

| Repo | Type | Node.js | Package Manager |
|------|------|---------|-----------------|
| `api-service` | Flat | 24 | npm |
| `auth-service` | Flat | 18 | yarn v1 |
| `worker` | Flat | 24 | pnpm |
| `platform` | Monorepo | 24 | yarn v4 |
| `data-pipeline` | Monorepo | 18 | npm |

`platform` has two packages: `ui` (has its own `devbox.json` adding storybook) and
`shared` (no `devbox.json`, inherits from `platform`). `data-pipeline` has `ingest`
(own `devbox.json`) and `transform` (inherits from `data-pipeline`).

### Flat Repo Setup

Setting up `api-service` from scratch:

```bash
cd <project-root>
mkdir api-service
cd api-service

# Create the direnv boundary
ln -s ../.envrc.default .envrc
direnv allow .

# Create the devbox boundary
devbox init
devbox add nodejs@24 npm@latest

# Create per-project config
echo 'NPM_CONFIG_PREFIX="$PWD/.devbox/npm-global"' > .envrc.local
echo 'PATH_add "$PWD/.devbox/npm-global/bin"' >> .envrc.local

# Create committed env vars
echo 'NODE_ENV=development' > .env.local

# Reload
direnv allow .
```

After this, `cd api-service` gives you nodejs@24, npm, and an isolated global bin
directory. `npm install -g typescript` puts `tsc` in
`api-service/.devbox/npm-global/bin/`, not the system-wide location.

### Monorepo Setup

Setting up `platform` with a nested package:

```bash
cd <project-root>
mkdir -p platform/packages/ui platform/packages/shared
cd platform

# Monorepo root boundary
ln -s ../.envrc.default .envrc
devbox init
devbox add nodejs@24 yarn@4
direnv allow .

# Package with its own devbox
cd packages/ui
ln -s ../../../.envrc.default .envrc
devbox init
devbox add storybook@latest
direnv allow .

# Package that inherits — only needs .envrc for env var boundary
cd ../shared
ln -s ../../../.envrc.default .envrc
direnv allow .
```

When inside `platform/packages/ui/`, three devbox layers are active: root, platform,
and ui. When inside `platform/packages/shared/`, only two: root and platform. `shared`
participates in direnv (can have `.env.local` and `.envrc.local`) but has no devbox of
its own.

### Switching Between Repos

```bash
cd <project-root>/api-service
node --version    # v24.x
which npm         # api-service/.devbox/nix/profile/default/bin/npm

cd ../auth-service
node --version    # v18.x — completely different runtime
which yarn        # auth-service/.devbox/nix/profile/default/bin/yarn
which npm         # not found or different location — api-service's npm is gone

cd ../platform/packages/ui
node --version    # v24.x — from platform's devbox
which storybook   # ui/.devbox/nix/profile/default/bin/storybook
```

Each `cd` is a clean swap. No state from the previous repo remains. The shell
environment is fully rebuilt for the new directory.

### Common Mistakes to Avoid

**Loading `.env` files in direnv.** Sensitive data ends up in the shell environment —
visible in `env`, process listings, and every child process. Use `.env.local` for
committed config and let applications read `.env` directly at runtime.

**Duplicate loading blocks.** If `.env.local` or `.envrc.local` is loaded more than once
in `.envrc.default`, variables may be processed twice or in unexpected order. Each file
should appear exactly once in the loading sequence.

**Using `$PWD` instead of `ENVRC_DIR`.** In `.envrc.default`, `$PWD` is where the user
cd'd into, not necessarily where the `.envrc` symlink and `devbox.json` live. Always use
`ENVRC_DIR` (resolved via `BASH_SOURCE[0]`) for paths that reference the project
directory.

**Putting `PATH_add` before `source_up_if_exists`.** The PATH addition will be buried
under everything the parent chain adds. `PATH_add` must come after `source_up_if_exists`
— the safest place is `.envrc.local`.

**Setting environment variables in `.envrc.local`.** Use `.env.local` for environment
variables and `.envrc.local` for bash scripts only. Mixing them makes it unclear which
file is responsible for what.

**Forgetting to gitignore `.devbox/`.** Devbox does not automatically add `.devbox/` to
`.gitignore`. It must be added explicitly, or the nix environment and isolated assets
end up in version control.

## Verification Checklist

Before testing the devbox+direnv system, verify the shell prerequisites are in place.

### Shell Prerequisites

`~/.zshenv` runs for every zsh session — both interactive (your terminal) and
non-interactive (scripts, Claude Code). It must load homebrew and devbox global at the
top to establish the base PATH. These just add binaries to PATH statically — they do
not make direnv trigger on `cd`. Without the direnv hook, a non-interactive script that
changes directories gets no project isolation — no devbox activation, no `.env.local`
loading, just the base PATH with homebrew, devbox global, and system binaries.

The `if [[ -n "$CLAUDECODE" ]]` guard selectively enables the direnv hook for Claude
Code sessions, which are non-interactive. This gives Claude Code the full
devbox+direnv system when it `cd`s into projects. The guard could be removed entirely
to give all non-interactive shells access to direnv, or additional conditions could be
added to control exactly which tools and scripts participate.

These lines must be at the top of their respective files — before any other
configuration. Homebrew and devbox global establish the base PATH that everything else
depends on. If other setup code runs first and modifies PATH, the priority order becomes
unpredictable.

```bash
# ~/.zshenv
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(/usr/local/bin/devbox global shellenv --init-hook)"

if [[ -n "$CLAUDECODE" ]]; then
  eval "$(direnv hook zsh)"
  eval "$(direnv export zsh)"
fi
```

`~/.zshrc` runs for interactive terminal sessions only. It must load the direnv hook so
that `cd` triggers direnv in your terminal. Homebrew and devbox global are already loaded
by `~/.zshenv` — loading them again here is redundant but harmless.

```bash
# ~/.zshrc
eval "$(direnv hook zsh)"
```

Verify the prerequisites:

```bash
which brew        # Expected: /opt/homebrew/bin/brew
which devbox      # Expected: a path under devbox global
direnv status     # Expected: shows loaded/allowed status
```

### System Checks

After the shell prerequisites are confirmed, run these checks:

```bash
# 1. Runtime isolation — different repos get different versions
cd <project-root>/api-service
node --version    # Expected: v24.x
cd ../auth-service
node --version    # Expected: v18.x

# 2. Clean switching — no bleed between repos
cd <project-root>/api-service
npm install -g typescript
which tsc         # Expected: api-service/.devbox/npm-global/bin/tsc
cd ../auth-service
which tsc         # Expected: not found (auth-service never installed it)

# 3. Global isolation — installs are scoped
cd <project-root>/api-service
which tsc         # Expected: still in api-service/.devbox/npm-global/bin/tsc

# 4. Monorepo layering — inner devbox wins
cd <project-root>/platform/packages/ui
which storybook   # Expected: ui/.devbox/nix/profile/default/bin/storybook
node --version    # Expected: v24.x (from platform's devbox)

# 5. Inheritance — no devbox.json still gets parent tools
cd <project-root>/platform/packages/shared
node --version    # Expected: v24.x (inherited from platform)
which storybook   # Expected: not found (only ui has storybook)

# 6. Package manager isolation
cd <project-root>/api-service
which npm         # Expected: points to api-service's devbox
cd ../auth-service
which yarn        # Expected: points to auth-service's devbox
which npm         # Expected: not api-service's npm

# 7. PATH priority — innermost project on top
cd <project-root>/platform/packages/ui
echo $PATH | tr ":" "\n" | grep devbox | head -5
# Expected: ui paths first, then platform paths, then root paths
```

If any check returns an unexpected result, the isolation is broken. Review the
activation flow output (`echo` messages from `.envrc.default` and the bootstrap) to
identify which step failed.
