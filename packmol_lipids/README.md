# Lipid conformations for Packmol.jl

One conformation of each of seven common phospholipids (CHARMM36 atom names and order),
chosen to pack well in membranes, and the 20 best candidates of each:

| Lipid | Files | Head atom | Chain-end atoms | Area per lipid that packs (Å²) |
|:------|:------|:---------:|:---------------:|:------------------:|
| POPC | `popc.pdb`, `popc_conformations.pdb` | 1 (N)   | 88 (C218), 131 (C316) | 64 |
| POPE | `pope.pdb`, `pope_conformations.pdb` | 1 (N)   | 79 (C218), 122 (C316) | 57 (1 of 2 runs) |
| POPS | `pops.pdb`, `pops_conformations.pdb` | 1 (N)   | 81 (C218), 124 (C316) | 63 |
| POPG | `popg.pdb`, `popg_conformations.pdb` | 1 (C13) | 81 (C218), 124 (C316) | 66 |
| DPPC | `dppc.pdb`, `dppc_conformations.pdb` | 1 (N)   | 84 (C216), 127 (C316) | 63 |
| DOPC | `dopc.pdb`, `dopc_conformations.pdb` | 1 (N)   | 88 (C218), 135 (C318) | 67 |
| DMPC | `dmpc.pdb`, `dmpc_conformations.pdb` | 1 (N)   | 78 (C214), 115 (C314) | 61 |

Each `<lipid>.pdb` is centered at the origin, with the axis from the midpoint of the chain
ends to the head atom along +z. `<lipid>_conformations.pdb` has the 20 most rod-like
conformations (largest asphericity, as computed by `Packmol.shape_descriptors`), one per
model, aligned the same way; its first model is `<lipid>.pdb`.

The areas are those at which a bilayer of 60 copies per leaflet of `<lipid>.pdb` packed
(Packmol.jl, tolerance 2.0 Å, periodic in x and y), with the chain ends constrained below
z = 6 Å (above z = -6 Å in the other leaflet) and the head atom above z = 6 + 0.85 L
(below -(6 + 0.85 L)), where L is the distance from the head atom to the midpoint of the
chain ends. Keeping the head atoms in a narrow band is what makes the packing work: with
the heads only above 6 + 0.5 L, most of these packings fail.

## How they were generated

`protocol/` has the scripts (`run.sh` runs everything):

1. Each lipid is built from its internal coordinates with psfgen (`build.tcl`, CHARMM36
   topology).
2. 2 ns of Langevin dynamics at 500 K in vacuum (NAMD, `lipid.namd`), with Colvars
   restraints (`<LIPID>_chains.colvars`) that keep the molecule membrane-like: a lower wall
   on the distance from the head atom to the midpoint of the chain ends, an upper wall of
   6 Å on the distance between the two chain ends, and a lower wall on the distance from
   the head atom to each chain end (0.92 (8 + n), n = carbons of the chain, minus a few Å
   for the smaller headgroups). Without the walls on each chain end, the chains coil and
   the frames are too short and thick to pack; without any restraint, the most rod-like
   frames are T-shaped, with the two chains in opposite directions.
3. The frames (one every 2 ps, 1001 in total) are written as the models of a PDB file
   (`frames.tcl`), and the most rod-like ones are selected with
   `Packmol.select_conformations` (`shape = :rod`).
