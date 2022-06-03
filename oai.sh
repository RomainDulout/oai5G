#!/bin/bash

#RFSIMULATOR=server ./nr-softmodem -O ../
#../../gnb.conf --sa -E --rfsim --nokrnmod 1 --log_config.global_log_options level,nocolor,time

# Variables
MAX_UE=10
UE=0



# Functions 
function help()
{
    echo "-------------------------------------------------------------------------------------------"
    echo "OAI script parameters :"
    echo " "
    echo "    -I : Pull docker images needed for the CORE and RAN (only once)"
    echo "--core : Run OAI 5G CORE (UDR / NRF / AMF / SMF / UPF / DATA-NETWORK)"
    echo "         /!\ run 5G CORE only once, or every time the simulator is restarted"
    echo " --ran : Run OAI 5G RAN with the number of UE desired"
    echo "--help : Display this help section"
    echo "--stop : Stop all the simulator by removing all containers"
    echo "--stat : Running different simulation use cases and print results to results folder"
    echo "         |--> IPERF: Running iperf server in data plane and iperf client on each UEs"
    echo "-------------------------------------------------------------------------------------------"
    echo "Steps :"
    echo " "
    echo "(0) Run once -I to pull docker images needed for the simulator"
    echo "(1) Run --core to deploy OAI 5G CORE"
    echo "(2) Run --ran <number_of_UE> to deploy OAI 5G RAN with UEs (MAX UE = $MAX_UE)"
    echo "-------------------------------------------------------------------------------------------"

}

function args_error()
{
    echo "-------------------------------------------------------------------------------------------"
    echo "Use case : $0 <parameter1> <parameter2>"
    echo " |--> Run $0 --help to check all parameters"
    echo "-------------------------------------------------------------------------------------------"
    exit 1
}

function check_healthy()
{
    echo "-------------------------------------------------------------------------------------------"
    echo -n "Waiting services state = healthy : "
    
    healthy=0
    while [ $healthy -eq 0 ]; do
        docker-compose ps -a > healthy.tmp
        count=0
        while read line
        do 
            count=$(($count + $(echo $line | grep -c "(healthy)")))
        done < healthy.tmp
        if [ $count -eq $1 ];
        then
            healthy=$(($healthy + 1))
        fi
        sleep 10
    done
    rm healthy.tmp
    echo "DONE"
    echo "-------------------------------------------------------------------------------------------"
}

function args_error()
{
    echo "-------------------------------------------------------------------------------------------"
    echo "Use case : $0 <parameter1> <parameter2>"
    echo " |--> Run $0 --help to check all parameters"
    echo "-------------------------------------------------------------------------------------------"
    exit 1
}

# Run program to add UEs id/IMSI/Secret KEY to mysql UDM
function add_UE()
{
    echo "-------------------------------------------------------------------------------------------"
    echo "Adding UE to UDM :"
    python3 tools/add_UE_database.py
    echo "-------------------------------------------------------------------------------------------"   
    echo "5G CORE FULLY SET" 
    echo "    --> now run ./oai.sh --ran <number_UEs> (max UE = $MAX_UE)"
    echo "-------------------------------------------------------------------------------------------"   
}

function running_ran()
{
    echo "-------------------------------------------------------------------------------------------"
    echo "RUNNING gNB "
    echo "-------------------------------------------------------------------------------------------"
    docker-compose up -d gnb-dev;
    check_healthy 7;
    echo "gNB FULLY SET" 
    echo "-------------------------------------------------------------------------------------------"   
    echo "RUNNING $1 UEs :"
    echo "-------------------------------------------------------------------------------------------"
    for ((i=0 ; $1 - $i ; i++))
    do 
        echo "RUNNING UE n°$(($i+1))"
        echo "-------------------------------------------------------------------------------------------"
        docker-compose up -d "ue$(($i+1))";
        check_healthy $(($i+8));
    done
    echo "$1 UEs FULLY SET" 
    echo "-------------------------------------------------------------------------------------------"   
}

function install()
{
    pip3 install mysql-connector-python

    docker pull mysql:5.7
    docker pull oaisoftwarealliance/oai-amf:latest
    docker pull oaisoftwarealliance/oai-nrf:latest
    docker pull oaisoftwarealliance/oai-smf:latest
    docker pull oaisoftwarealliance/oai-spgwu-tiny:latest
    docker pull oaisoftwarealliance/oai-gnb:develop
    docker pull oaisoftwarealliance/oai-nr-ue:develop
    docker image tag oaisoftwarealliance/oai-amf:latest oai-amf:latest
    docker image tag oaisoftwarealliance/oai-nrf:latest oai-nrf:latest
    docker image tag oaisoftwarealliance/oai-smf:latest oai-smf:latest
    docker image tag oaisoftwarealliance/oai-spgwu-tiny:latest oai-spgwu-tiny:latest
    docker image tag oaisoftwarealliance/oai-gnb:develop oai-gnb:develop
    docker image tag oaisoftwarealliance/oai-nr-ue:develop oai-nr-ue:develop
}


# Switching programs 
if [ $# -eq 1 ]; 
then
    if [ $1 = "--help" ];
    then
        help
    elif [ $1 = "--core" ];
    then
        docker-compose up -d mysql nrf amf smf upf data_network;
        check_healthy 6;
        docker-compose ps -a;
        add_UE;
    elif [ $1 = "-I" ]
    then 
        install;
    elif [ $1 = "--test" ]
    then 
        echo "DEVELOPER TEST OPTION"
    elif [ $1 = "--stop" ]
    then 
        docker-compose down;
        echo "-------------------------------------------------------------------------------------------"
        echo "SIMULATOR COMPLETELY SHUT DOWN "
        echo "-------------------------------------------------------------------------------------------"
    else
        args_error;
    fi
elif [ $# -eq 2 ];
then   
    if [ $1 = "--ran" ];
    then

        if [ $2 -gt $MAX_UE ];
        then 
            UE=$MAX_UE
            running_ran $UE
        else
            UE=$2
            running_ran $UE
        fi 
    else
        args_error;
    fi
else
    args_error;
fi



