#!/bin/bash
# Builds each lipid with psfgen (CHARMM36), and runs 2 ns of Langevin dynamics at 500 K in
# vacuum with NAMD, with the Colvars restraints of LIPID_chains.colvars. The frames of each
# trajectory are written as the models of LIPID_chains_frames.pdb, from which the most
# rod-like ones are selected with Packmol.select_conformations.
#
# Usage: TOPPAR=/path/to/toppar NAMD=/path/to/namd3 ./run.sh
#
# TOPPAR is a CHARMM36 toppar directory (top_all36_lipid.rtf, par_all36_lipid.prm,
# stream/lipid/toppar_all36_lipid_cholesterol.str); vmd must be in the PATH.
set -e
cd "$(dirname "$0")"
: "${TOPPAR:?set TOPPAR to the CHARMM36 toppar directory}"
: "${NAMD:?set NAMD to the namd3 (or namd2) executable}"
sed "s#TOPPAR#$TOPPAR#g" build.tcl > build_local.tcl
for L in $(awk '{print $1}' lipids.txt); do
    # first internal coordinate of the residue: the three seed atoms of the build
    seed=$(awk -v r=$L '$1=="RESI"&&$2==r{f=1;next} f&&$1=="RESI"{f=0} f&&$1=="IC"{print $2, $3, $4; exit}' \
        $TOPPAR/top_all36_lipid.rtf | tr -d '*')
    vmd -dispdev text -e build_local.tcl -args $L $seed < /dev/null > build_$L.log 2>&1
    sed "s#TOPPAR#$TOPPAR#g; s/LIPID/$L/g" lipid.namd > ${L}_chains.namd
    $NAMD +p4 ${L}_chains.namd > ${L}_chains.log 2>&1
    vmd -dispdev text -e frames.tcl -args $L chains < /dev/null > frames_$L.log 2>&1
done
