# MAESTRO

Maestry is a simple utility to managa a cluster via Docker machine

## Dependencies
- Docker
- Docker Machine

## Create a cluster
This will create ``10`` instances associated with ``cluster-name``:
```
./maestro create cluster-name 10
```
It requires a ``DOCKER_MACHINE_OPTIONS`` variable to be set with
all the parameters you want to create your machine.

## Stop all instances in the cluster
```
./maestro down cluster-name
```

# Start all instances in the cluster
```
./maestro up cluster-name
```

# Run a script passing the instance as a parameter
This will iteracte through all the running instances
associated with ``cluster-name`` and execute the ``script.sh``
for each instance. The ``script.sh`` will receive the instance
name as the first argument ``$1``
```
./maestro run cluster-name run ./script.sh
```
