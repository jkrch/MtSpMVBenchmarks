function bench_all(n)

#    BenchmarkConstructors.bench_csr(n, n, 5/n, dense=false)
#    println("---------------------------------------------------------------------")

    BenchmarkMul.bench_builtin(n, n, 5/n)
    println("---------------------------------------------------------------------")

#    BenchmarkMul.bench_expmul(n, n, 5/n)
#    println("---------------------------------------------------------------------")

    BenchmarkIterative.bench_cg(n, "fdm2d")
    println("---------------------------------------------------------------------")

    BenchmarkIterative.bench_cg(n, "fdm3d")
    println("---------------------------------------------------------------------")

#    BenchmarkIterative.bench_minres(n, "symmindef")
#    println("---------------------------------------------------------------------")

#    BenchmarkIterative.bench_gmres(n, "fem2d")
#    println("---------------------------------------------------------------------")

    #BenchmarkIterative.bench_gmres(n, "nonsymm")
    #println("---------------------------------------------------------------------")
    
end
