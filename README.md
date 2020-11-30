# Workloads for Quantum Package.

Quantum Package is a not a QMC code. It is used to build high-accuracy
trial wave functions for QMC calculations. It is interfaced with CHAMP
and QMC=Chem.   It can  also compute integrals  (FCIDUMP files)  to be
given to NECI, or density matrices for  GammCor. It can be used as the
main input for TREX workflows.

Two workloads have  been prepared. A small one to  check that the code
works well, and a larger one to stress the machine. The small workload
runs  in one  minute on  4 cores,  and the  large one  takes about  10
minutes on 512 cores.

## Theory

We are  trying to  estimate the  Full Configuration  Interaction (FCI)
energy, namely  the exact  solution of the  Schrödinger equation  in a
finite  basis set.  The  scaling  is exponential  with  the number  of
electrons,  so we  are using  an  iterative alorithm  to approach  the
solution: the CIPSI algorithm.

The wave function  is expanded in a basis  of ``Slater Determinants``.
For  the  Benzene molecule,  the  FCI  space  is composed  of  10^{22}
determinants, and we try here  to find the best possible approximation
within a smaller number of determinants, around 10^6.

We  start with  a single  determinant (the  Hartree-Fock determinant).
Then, we use  perturbation theory to estimate the gain  in energy that
one would obtain by including each determinant, and we select the most
important ones  to increase the  size of the determinant  space. Then,
the Hamiltonian  operator is diagonalized  in the enlarged  space, and
the lowest eigenvector is the best possible approximation to the exact
solution within this space.  Then,  new determinants are selected, the
Hamiltonian is diagonalized, etc, and  the process is iterated until a
stopping criterion is reached.

At  each iteration,  on  has  the energy  ``E``  which  is the  lowest
eigenvalue of the Hamiltonian in  the truncated determinant space, and
we  have the  second-  order perturbative  correction  to the  energy,
``PT2``. ``E+PT2`` is an estimate of the FCI eneergy, and when the FCI
limit is  reached PT2=0, so  that the FCI  energy can be  estimated by
extrapolating E as a function of PT2.


## Technical details

This directory has qp2 as a submodule. So you should clone this directory
using:
```
git clone --recurse-submodules https://github.com/TREX-CoE/workload_quantum_package.git
```

Quantum Package is  written with the IRPF90 Fortran  generator.  It is
parallelized  with  OpenMP.   Task-based  Distributed  parallelism  is
implemented using the ZeroMQ  library. Fortran executables communicate
with a task scheduler written  in OCaml. A main single-node simulation
is run, and multiple MPI helpers can join to increase the computational
resources.

To  download   and  install   all  the   dependencies,  you   can  run
``./configure  -i  all`` in  the  ``qp2``  directory. It  should  work
automatically.   Then, to  adjust the  compiler parameter,  you should
copy one  of the configuration  files in the ``config``  directory and
modify it.  For example:

```
cp config/ifort_avx_mpi.cfg config/my_config.cfg
```

Edit the new file, and re-configure:

```
./confgure -c config/my_config.cfg
```

Now you can build the program using ``make`` in the ``qp2`` directory.



To  run in  multi-node with  SLURM, instead  of using
```
qp_run  fci
benzene
```

you can use
```
qp_srun fci benzene
```

This last  command will automatically  launch the master  instance, and
one MPI helper on N-1 nodes.
