#
# Creates the tarball of a set of files, and prints its Artifacts.toml entry.
# From the root of this repository:
#
#   julia make_artifact.jl <set> <version>
#
# for example `julia make_artifact.jl pdbtools 2`, which creates `pdbtools.tar.gz`, to be
# published in the release `pdbtools-v2`.
#
using Pkg.Artifacts, SHA

set, version = ARGS[1], ARGS[2]
hash = create_artifact() do dir
    for f in readdir(set)
        cp(joinpath(set, f), joinpath(dir, f))
    end
end
tarball = "$set.tar.gz"
archive_artifact(hash, tarball)
println("""
[$(set)_test_files]
git-tree-sha1 = "$(bytes2hex(hash.bytes))"
lazy = true

    [[$(set)_test_files.download]]
    url = "https://github.com/m3g/MolSimTestFiles/releases/download/$set-v$version/$tarball"
    sha256 = "$(bytes2hex(open(sha256, tarball)))"
""")
