import numpy as np
from smartsim import Experiment
from smartredis import Client
import time

"""
Launch a distributed, in memory database cluster and use the
SmartRedis python client to send and receive some numpy arrays.
This example runs in an interactive allocation with at least three
nodes and 1 processor per node.
i.e. qsub -l select=3:ncpus=1 -l walltime=00:10:00 -A <account> -q premium -I
"""
def launch_cluster_orc(experiment, port):
    """Just spin up a database cluster, check the status
    and tear it down"""
    db = experiment.create_database(port=port, db_nodes=1, interface='lo')
    # generate directories for output files
    # pass in objects to make dirs for
    experiment.generate(db, overwrite=True)
    # start the database on interactive allocation
    experiment.start(db)
    # get the status of the database
    statuses = experiment.get_status(db)
    print(f"Status of all database nodes: {statuses}")
    return db
# create the experiment and specify auto because SmartSim will
# automatically detect that Theta is a Cobalt system
exp = Experiment("launch_cluster_db", launcher="local")
db_port = 6781
# start the database
db = launch_cluster_orc(exp, db_port)
# test sending some arrays to the database cluster
# the following functions are largely the same across all the
# client languages: C++, C, Fortran, Python
# only need one address of one shard of DB to connect client
db_address = db.get_address()[0]
client = Client(address=db_address, cluster=False)
print(f'created client at address {db_address}')

client.put_tensor("i_sim_done", np.array([0.]))
client.put_tensor("i_yaws_done", np.array([1.]))

for it in range(1000):
    print(f'Iteration: {it}')
    yaws = it%60. - 30.
    print(f'Yaw angle: {yaws}')
    print('Sending...')
    client.put_tensor("i_yaws", np.array([yaws]))
    client.put_tensor("i_yaws_done", np.array([1.]))
    print(f'Sent i_yaws_done = {client.get_tensor("i_yaws_done")}')
    print('Waiting for update...')
    while(client.get_tensor("i_sim_done") == False):
        continue
    print('Simulation updated\n')
	# read reward, observation
    client.put_tensor("i_sim_done", np.array([0.]))

# shutdown the database because we don't need it anymore
exp.stop(db)


# SR_DB_TYPE="Standalone" SSDB=127.0.0.1:6780 python send_recv.py
