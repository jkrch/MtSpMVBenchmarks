# MtSpMVBenchmarks

This repository is a collection of benchmarks for the Julia package [MtSpMV](https://github.com/jkrch/MtSpMV.jl).

Because the number of Julia threads has to be set before the start of a Julia session and can not be changed from inside it (other then e.g. the number of BLAS threads).
the benchmarks in this repository have to be run by a shell script, in which the number of Julia threads can be controlled.

## Usage

```console
foo@bar:~$ cd path/to/dir
foo@bar:~$ git clone https://github.com/jkrch/MtSpMVBenchmarks
```
Clones the repository to your computer (replace path/to/dir with the directory where you want to repo to be cloned to).

```console
foo@bar:~$ cd src/MtSpMVBenchmarks
```
Moves to the direcotry where the benchmarks can be run from.

### Number of threads

```console
foo@bar:~$ ./run_nthreads julia 'ser par mkl' 'csr csc' '1 64' spmv poisson 1000
```
Benchmarks the serial CSR and CSC MatVec of SparseArrays.jl, the multithreaded CSR MatVec MtSpMV.jl and the multithreaded CSR and CSC MatVec of MKLSparse.jl for 1,2,3,4 threads for the generated poisson matrix of size 100x100.

### Matrix size

```console
foo@bar:~$ src/run_matsize julia 'ser par mkl' 'csr' '2 4 8' cg poisson '200 400 600 800 1000'
```



#### Number of threads

```console
foo@bar:~$ src/nthreads_iter julia_link solver linsys n mkl_csr mkl_csc
```
| Argument     | Description                                                        |
| :----------- | :----------------------------------------------------------------- |
| `julia_link` | Link to your Julia version (for usage of different build Julias)   |
| `solver`     | Iterative solver, choose from "cg", "minres", "bicgstabl", "gmres" |
| `linsys`     | Linear system type, choose from "fdm2d", "fdm3d", "fem2d"          |
| `n`          | Size of linear system                                              |
| `mkl_csr`    | Boolean, add benchmarks for CSR matrix-vector product from MKL     |
| `mkl_csc`    | Boolean, add benchmarks for CSR matrix-vector product from MKL     |


