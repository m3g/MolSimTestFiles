# Write the frames of a trajectory as the models of a PDB file
set lipid [lindex $argv 0]
set traj [lindex $argv 1]
mol new $lipid.psf
mol addfile ${lipid}_${traj}.dcd waitfor all
set n [molinfo top get numframes]
set out [open ${lipid}_${traj}_frames.pdb w]
set all [atomselect top all]
for {set i 0} {$i < $n} {incr i} {
    $all frame $i
    $all writepdb tmp_$lipid$traj.pdb
    puts $out [format "MODEL     %4d" [expr {$i + 1}]]
    set f [open tmp_$lipid$traj.pdb r]
    while {[gets $f line] >= 0} {
        if {[string range $line 0 3] eq "ATOM" || [string range $line 0 5] eq "HETATM"} { puts $out $line }
    }
    close $f
    puts $out "ENDMDL"
}
puts $out "END"
close $out
file delete tmp_$lipid$traj.pdb
puts "frames: $n"
exit
