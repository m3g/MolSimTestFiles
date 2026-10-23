# MolSimTestFiles

Test files of the packages of the [m3g](https://github.com/m3g) molecular simulation
ecosystem (PDBToolsBase.jl, PDBTools.jl, MolSimToolkit.jl, ComplexMixtures.jl, Packmol.jl).

The files are distributed as [lazy Julia artifacts](https://pkgdocs.julialang.org/v1/artifacts/):
they are not part of the installation of the packages, and are downloaded only when a test
(or a documentation example) needs them. Artifacts are stored by content hash, so packages
that use the same set of files share a single download.

## Layout

Each directory is a set of files, published as one artifact:

| Directory  | Release tag     | Used by                   |
|:-----------|:----------------|:--------------------------|
| `pdbtools` | `pdbtools-v1`   | PDBToolsBase.jl, PDBTools.jl |

The release asset of each set is a tarball of the files of the directory (`<set>.tar.gz`),
with the files at the root of the tarball.

## Using a set in a package

Add the artifact to the `Artifacts.toml` file of the package, with `lazy = true`. For
example, for the `pdbtools` set:

```toml
[pdbtools_test_files]
git-tree-sha1 = "7f3bcdf94edc147fd0e2e14370de3e30f584ef64"
lazy = true

    [[pdbtools_test_files.download]]
    url = "https://github.com/m3g/MolSimTestFiles/releases/download/pdbtools-v1/pdbtools.tar.gz"
    sha256 = "e84ec74dac6645df4bf24d46919b50e35f785ed93880716307aec551909d1390"
```

and access the files through a function, so that the download happens only when a file is
needed (not when the package is precompiled):

```julia
using LazyArtifacts: @artifact_str
test_file(name::AbstractString) = joinpath(artifact"pdbtools_test_files", name)
```

The package must depend on the `LazyArtifacts` standard library.

## Adding or updating a set

Released tarballs are never modified: a change in a set is a new release (e.g.
`pdbtools-v2`), and the packages update their `Artifacts.toml` to the new hashes when they
need the new files.

1. Add or update the files in the directory of the set, and commit.
2. Create the tarball and compute its hashes (from the root of this repository):

    ```julia
    using Pkg.Artifacts, SHA
    set = "pdbtools"
    hash = create_artifact() do dir
        for f in readdir(set)
            cp(joinpath(set, f), joinpath(dir, f))
        end
    end
    archive_artifact(hash, "$set.tar.gz")
    println("git-tree-sha1 = ", bytes2hex(hash.bytes))
    println("sha256 = ", bytes2hex(open(sha256, "$set.tar.gz")))
    ```

3. Publish the tarball in a new release:

    ```bash
    gh release create pdbtools-v2 pdbtools.tar.gz --title "pdbtools-v2"
    ```

4. Update the table above, and the `Artifacts.toml` of the packages that use the set.
