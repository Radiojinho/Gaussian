#!/usr/bin/bash
#$ -V
#$ -cwd
#$ -N g16.parallel
#$ -e g16.perror
#$ -o g16.pout
#$ -pe mpi 12
#$ -j y

export WDIR=`pwd`
echo $WDIR
export g16root=/export/apps/g16_b01_sse4
source ${g16root}/g16/bsd/g16.profile
export OMP_NUM_THREADS=12

# Loop over all .com files in the current directory
for file in *.com; do
  export inp=`basename ${file} .com`
  echo ${inp}
  if [ ! -e ${inp}.log ]; then
    export myscratch=/state/partition1/$USER/g16_${JOB_ID}
    if [ ! -e $myscratch ]; then
            mkdir -p $myscratch
    fi
    export GAUSS_SCRDIR=$myscratch
  
    cp ${file} $myscratch
    cd $myscratch
    g16 ${inp}.com
    echo 'job done for' ${inp}
    rsync -avz ${inp}.* $WDIR
    ls $WDIR
    cd $WDIR
    pwd
    \rm -rf $myscratch
  fi
done

exit 0
