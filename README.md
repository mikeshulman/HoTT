# HoTT Classes

Based on [Math Classes](https://math-classes.github.io/) but for [HoTT](https://github.com/hott/hott).

Notable differences:
- less stuff
- no setoids (HoTT has quotient types)

# Publications

See SCIENCE.md

# Build

You can follow what travis does, or:

- Dependencies: same as Coq trunk. Coq's `configure` should warn you if some are missing.

- Get: [Coq with inductive-inductive types](https://github.com/mattam82/coq/tree/IR), [HoTT modified to compile with Coq trunk](https://github.com/ejgallego/HoTT/tree/mz-8.7) and HoTTClasses (this repository).

	- ZIP archives: https://github.com/mattam82/coq/archive/IR.zip https://github.com/ejgallego/HoTT/archive/mz-8.7.zip and https://github.com/SkySkimmer/HoTTClasses/archive/master.zip

- In this guide the resulting folders are called respectively `coq-IR/`, `HoTT/` and `HoTTClasses/`.

- In the coq-IR/ folder:

    - `./configure -local`

	- `make coqlight coqide`

	You can use just `make` but then you will compile the whole Coq library for no reason. The `coqlight` target still builds part of the library but it's not as bad.

- In the HoTT/ folder:

	- `./autogen.sh` (if using archives it will note that it isn't in a git repo, this is normal)

	- `./configure COQBIN=/path/to/coq-IR/bin` (note the `/bin` at the end)

	- `make`

- In HoTTClasses/

	- Add HoTT/ to your `$PATH`. Alternatively, `export HOQDIR=/path/to/HoTT/`.

	- `./configure`

	- `make`

# Using IDEs

## Coqide

The `./ide` script only works if HoTT/ is in your `$PATH`, use `/path/to/HoTT/hoqide -R theories HoTTClasses` otherwise.

## Proof General

[Proof General](https://github.com/ProofGeneral/PG/) understands the `_CoqProject` produced by `./configure`. `./configure` also sets up `.dir-locals.el` so that PG calls the right hoqtop program.
