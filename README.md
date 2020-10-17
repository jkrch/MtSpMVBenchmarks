# MtSpMVBenchmarks

This repository is a collection of benchmarks for the Julia package [MtSpMV](https://github.com/jkrch/MtSpMV.jl).

Because the number of Julia threads has to be set before the start of a Julia session and can not be changed from inside it (other then e.g. the number of BLAS threads).
the benchmarks in this repository have to be run by a shell script, in which the number of Julia threads can be controlled.

## Usage

Clone the repository to the (high performance) computer you want to run the benchmarks.

### Sparse matrix-vector product

#### Number of threads

```console
foo@bar:~$ src/nthreads_spmv julia_link m n nnzrow mkl_csr mkl_csc
```
| Argument     | Description                                                      |
| :----------- | :--------------------------------------------------------------- |
| `julia_link` | Link to your Julia version (for usage of different build Julias) |
| `m`          | Number of matrix rows                                            |
| `n`          | Number of matrix columns                                         |
| `nnzrow`     | Number of approx. nonzeros per row                               |
| `mkl_csr`    | Boolean, add benchmarks for CSR matrix-vector product from MKL   |
| `mkl_csc`    | Boolean, add benchmarks for CSR matrix-vector product from MKL   |

#### Matrix size

```console
foo@bar:~$ src/matsize_spmv julia_link nthreads N nnzrow mkl_csr mkl_csc
```
| Argument     | Description                                                      |
| :----------- | :--------------------------------------------------------------- |
| `julia_link` | Link to your Julia version (for usage of different build Julias) |
| `nthreads`   | Number of threads                                                |
| `N`          | Max. matrix size                                                 |
| `nnzrow`     | Number of approx. nonzeros per row                               |
| `mkl_csr`    | Boolean, add benchmarks for CSR matrix-vector product from MKL   |
| `mkl_csc`    | Boolean, add benchmarks for CSR matrix-vector product from MKL   |

### Iterative solvers

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


