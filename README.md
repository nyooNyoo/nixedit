## nixedit - NixOS Rebuilding tool

`nixedit` is a simple command-line tool to automate all steps of rebuilding.

### Features:
- Search Configure Build Backup Update Delete in one step.
- Search packages available online with `--search`.
- Integrates with GitHub to upload backups of your configuration.

### Installation Instructions

You can install `nixedit` using the provided `default.nix` file. Follow these steps to build package.

#### Step 1: Clone the Repository

First, clone this repository containing the `default.nix` and `src`.

```
git clone https://github.com/fndov/nixedit.git
cd nixedit
nix-build            # Compile nixedit
nix-env -i ./result  # Install pacakge
```
```
# Uninstall package using:
nix-env --uninstall nixedit
