#!/usr/bin/env bash

arguments=$*

for i in "$@"
do
case $i in
    --b2d)
    b2d=1
    shift # past argument with no value
    ;;
    --rebuild)
    rebuild=1
    shift # past argument with no value
    ;;
    *)
            # unknown option
    ;;
esac
done

if [ "$(expr substr $(uname -s) 1 5 2>/dev/null)" != "Linux" ]; then
    syncd run
    ssh docker@192.168.10.10 "bash -s" -- < provision.sh --b2d $arguments
    exit
fi

docker --version >/dev/null 2>&1 || { echo "Docker is required to run this. Aborting..." >&2; exit 1; }
docker-compose -version >/dev/null 2>&1 || { echo "Docker-compose is required to run this. Aborting..." >&2; exit 1; }

if [  -n "$b2d" ]
then
    PROJECTPATH="/projects/OpenCPU"
    sudo chown -R docker:staff $PROJECTPATH
else
    PROJECTPATH=`pwd`
    sudo chown -R `whoami` $PROJECTPATH
fi

export PROJECTPATH=$PROJECTPATH

docker rm -f ppv3-opencpu > /dev/null 2>&1 || true

if [ -n "$rebuild" ]
then
    docker rmi -f ppv3/opencpu > /dev/null 2>&1 || true
fi

for f in ~/scripts/*.sh; do source $f; done

docker build -t ppv3/opencpu $PROJECTPATH

#run all containers and start services
cd $PROJECTPATH && docker-compose up -d


