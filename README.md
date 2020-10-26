# MtSpMVBenchmarks

This repository is a collection of benchmarks for the Julia package [MtSpMV](https://github.com/jkrch/MtSpMV.jl).

Because the number of Julia threads has to be set before the start of a Julia session and can not be changed from inside it (other then e.g. the number of BLAS threads).
the benchmarks in this repository have to be run by a shell script, in which the number of Julia threads can be controlled.

## Usage

```console
foo@bar:~$ cd <dir>
foo@bar:~/dir$ git clone https://github.com/jkrch/MtSpMVBenchmarks
```
Clones the repository to your computer (replace <dir> with the directory where you want the repository to be cloned to).

```console
foo@bar:~/dir$ cd MtSpMVBenchmarks/src
```
Changes to the directory where the benchmarks can be run from.

### Number of threads

```console
foo@bar:~/dir/MtSpMVBenchmarks/src$ ./run_nthreads julia 'ser par mkl' 'csr csc' '1 64' spmv poisson 1000
```
Benchmarks the serial CSR and CSC MatVec of SparseArrays.jl, the multithreaded CSR MatVec MtSpMV.jl and the multithreaded CSR and CSC MatVec of MKLSparse.jl for 1,2,3,4 threads for the generated poisson matrix of size 1000x1000.

### Matrix size

```console
foo@bar:~/dir/MtSpMVBenchmarks/src$ run_matsize julia 'ser par mkl' 'csr' '2 4 8' cg poisson '200 400 600 800 1000'
```



#### Number of threads

```console
foo@bar:~$ src/nthreads_iter julia_link solver linsys n mkl_csr mkl_csc
```
| Argument     | Description |
| :----------- | :--- |
| `julia_link` | Link to your Julia version (for usage of different build Julias) |
| `kernels`    | 'ser' = SparseArrays.jl |
|              | 'par' = MtSpMV.jl |
|              | 'mkl' = MKLSparse.jl |
| `formats`    | 'csr' = CSR MatVec |
|              | 'csc' = CSC MatVec |
| `nthreads`   | 'minthreads maxthreads' |
| `solver`     | 'spmv' = sparse matrix-vector product |
|              | 'cg', 'minres', 'gmres', 'bicgstabl' = iterative solver |
| `matrix'     | name of the matrix from MatrixDepot.jl |
| 'n'          | size of the matrix |

## ToDo
* Documentation
* Preconditioning
* GFlops (maybe)
* Unit testing (Julia and Shell)
