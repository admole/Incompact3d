# Python
export SR_DB_TYPE="Standalone"
export SSDB=127.0.0.1:6781
python controller.py&

sleep 20

LD_LIBRARY_PATH=/home/amole/Code/Incompact3d/build/smartredis-build/smartredis/install/lib:$LD_LIBRARY_PATH \

# mpirun -np 8 ../../../../build/bin/xcompact3d > log.x3d
../../../../../build/bin/xcompact3d > log.x3d
