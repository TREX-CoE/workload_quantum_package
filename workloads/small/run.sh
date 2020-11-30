#!/bin/bash

source ../../qp2/quantum_package.rc

qp_create_ezfio -b 6-31g h2o.xyz -o h2o

qp_run scf h2o > h2o.scf.out

grep "SCF energy" h2o.scf.out

qp_set_frozen_core h2o

qp_run fci h2o > h2o.fci.out

grep "E+PT2" h2o.fci.out | tail -1
