package require psfgen
set lipid [lindex $argv 0]
set seed [lrange $argv 1 3]
resetpsf
topology TOPPAR/top_all36_lipid.rtf
topology TOPPAR/stream/lipid/toppar_all36_lipid_cholesterol.str
segment L { first none; last none; residue 1 $lipid }
coord L 1 [lindex $seed 0] {0.0 0.0 0.0}
coord L 1 [lindex $seed 1] {1.5 0.0 0.0}
coord L 1 [lindex $seed 2] {2.0 1.4 0.0}
guesscoord
writepsf $lipid.psf
writepdb $lipid.pdb
exit
