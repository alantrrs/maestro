#!/usr/bin/env bash

create () {
  # Create a cluster
  if [ -z "$DOCKER_MACHINE_OPTIONS" ]; then
    echo "Missing DOCKER_MACHINE_OPTIONS"
    echo "Usage DOCKER_MACHINE_OPTIONS=\"...\" ./maestro.sh create cluster-name N"
    exit 0
  fi
  echo "Cluster name: $1"
  echo "Machines: $2"
  for i in $(seq 1 $2); do
    INSTANCE="$1-$i"
    echo "Creating instance: $INSTANCE"
    docker-machine create $DOCKER_MACHINE_OPTIONS $INSTANCE
  done
}

up () {
  CLUSTER=$1
  STOPPED=$(docker-machine ls -q --filter name=$CLUSTER* --filter state=stopped)
  echo $STOPPED
  if [ -z "$STOPPED" ]; then
    echo "No stopped instances associated to cluster $CLUSTER"
    exit 0
  fi
  # Start all instances
  for instance in $STOPPED; do
    echo "Starting instance $instance"
    docker-machine start $instance
    docker-machine regenerate-certs $instance
  done
}

down () {
  CLUSTER=$1
  RUNNING=$(docker-machine ls -q --filter name=$CLUSTER* --filter state=running)
  echo $RUNNING
  if [ -z "$RUNNING" ]; then
    echo "No running instances associated to cluster $CLUSTER"
    exit 0
  fi
  # Stop all instances
  for instance in $RUNNING; do
    echo "Stop instance $instance"
    docker-machine stop $instance
  done
}

run () {
  CLUSTER=$1
  CMD=$2
  RUNNING=$(docker-machine ls -q --filter name=$CLUSTER* --filter state=running)
  echo $RUNNING
  if [ -z "$RUNNING" ]; then
    echo "No running instances associated to cluster $CLUSTER"
    exit 0
  fi
  # Stop all instances
  for instance in $RUNNING; do
    echo "Run command: $CMD $instance"
    $CMD $instance
  done
}

## FIXME: scale is not tested
scale () {
  CLUSTER=$1
  SCALE=$2
  AVAILABLE=($(docker-machine ls -q --filter name=$CLUSTER*))
  RUNNING=($(docker-machine ls -q --filter name=$CLUSTER* --filter state=running))
  # Scale instances
  if [ "$SCALE" -gt "${#AVAILABLE[@]}" ]; then
    echo "Not enought available instances. Total available instances: ${#AVAILABLE[@]}"
    exit 0
  fi
  if [ "$SCALE" -eq "${#RUNNING[@]}" ]; then
    echo "Already on desired state"
    exit 0
  fi
  STOPPED=($(docker-machine ls -q --filter name=$CLUSTER* --filter state=stopped))
  if [ "$SCALE" -gt "${#RUNNING[@]}" ]; then
    DIFF=`expr $SCALE - ${#RUNNING[@]}`
    echo "DIFF: $DIFF"
    INSTANCES=("${STOPPED[@]:0:$DIFF}")
    echo "INSTANCES: $INSTANCES"
    for instance in $INSTANCES; do
      echo "Starting instance $instance"
      # docker-machine start $instance
    done
  fi
  if [ "$SCALE" -lt "${#RUNNING[@]}" ]; then
    DIFF=`expr ${#RUNNING[@]} - $SCALE`
    INSTANCES=("${RUNNING[@]:0:$DIFF}")
    for instance in $INSTANCES; do
      echo "Stoping instance $instance"
      # docker-machine start $instance
    done
  fi
}

# maestro create cluster-name 5
if [ $1 = "create" ]; then
  create $2 $3
fi
# maestro down cluster-name
if [ $1 = "down" ]; then
  down $2
fi
# maestro up cluster-name
if [ $1 = "up" ]; then
  up $2
fi

# maestro scale cluster-name 5
if [ $1 = "scale" ]; then
  scale $2 $3
fi

# maestro run cluster-name run ./script.sh
if [ $1 = "run" ]; then
  run $2 $3
fi
