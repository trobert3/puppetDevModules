#!/bin/bash

######################################
#
# ena_control - Deployment and control script for Multitailer applications.
#
#   $Revision: 1.1 $
#   $LastChangedDate: 2015-09-14
#   $LastChangedBy: pchopra $
#
######################################

######################################
# CONFIGURATION BLOCK
######################################

# !!! WARNING !!! These setting can be overridden by env_enablers.sh !!! WARNING !!!

cd `dirname $0`

SYSNAME=`uname -s`
SCRIPTNAME=`basename $0`
SCRIPTUSER=`id`
SCRIPTCALLER=`perl -e 'print getlogin || getpwuid($<), $/'`
SCRIPTTIME=`date +%F" "%H:%M:%S`
SCRIPTLOGTIME=`date +%Y%m%d`

if [ $SYSNAME == "SunOS" ]; then
	PS=/usr/ucb/ps
else
	PS=ps
fi


APPS_DIR=/opt/SP/apps
APP_HOME=/opt/SP/apps/multitailer/
LOGLEVEL=debug
PID_DIR=/var/SP/run/multitailer/
LOG_DIR=/var/SP/log/multitailer/
JDK_FOLDER=jdk1.7.0_55

PID_FILE=${PID_DIR}multitailer.pid
export LOG_FILE=${LOG_DIR}multitailer.log

export CONFIG_FILE=conf/multitailer-config.xml
export APP_NAME="multitailer"


export JAVA_HOME=${APPS_DIR}/common/${JDK_FOLDER}
export PATH=$JAVA_HOME/bin:$PATH


print_usage() {
        cat <<END_USAGE

Usage:  ${SCRIPTNAME} [-m] [-a application] <COMMAND>
        Deployment and control script for ER Multitailer application.

        Options:
        -a APP          manually override the application to work for (e.g. er_core)
        -m              manually force MultiOpcoEnvironment mode
	-n		execute <COMMAND> without deploying from delivery server

        Commands:
        start           startup application*
        stop            shutdown application
        restart         restart application
        status          show application status

        (*) requires application to be stopped

        Common values for APP:
        er_core er_cc ppe er_batch

END_USAGE
exit 1
}

show_startup_settings() {
        echo "=================================="
        echo "APPLICATION:${APP_NAME}"
        echo "COMMAND    :${COMMAND}"
	echo "HOST APP	 :${HOST_APP}"
	echo "=================================="
}

# ----------------------------------
# Pidfile check
#-----------------------------------
pidcheck() {
        local PID_FILE=$1
        if [ -f $PID_FILE ]; then
                # Found a pid file
                ps -p `cat $PID_FILE` > /dev/null
                if [ $? -eq 0 ] ; then
                        return 1
                fi

                echo "Stale pidfile found ${PID_FILE}, so will be removed..."
                rm $PID_FILE
        fi
}

# ----------------------------------
# Application start
# ----------------------------------
application_start() {
        pidcheck ${PID_FILE}
        if [ $? -eq 0 ] ; then
                COMMAND="${APP_HOME}/bin/multitailer -c ${APP_HOME}/${CONFIG_FILE}"
                echo "Starting ${APP_NAME}..."
                nohup $COMMAND >> ${LOG_FILE} 2>&1 &
                echo $! > ${PID_FILE}
				echo "${APP_NAME} has been started."
        else
                echo "The ${APP_NAME} is already running. No action has been taken."
        fi
}

# ----------------------------------
# Application stop
# ----------------------------------
application_stop() {
        if [ -f ${PID_FILE} ] ; then
                echo "Stopping ${APP_NAME}..."
                kill `cat ${PID_FILE}`
                echo
                sleep 1
                rm -f ${PID_FILE}
				echo "${APP_NAME} is now stopped."
        else
                echo "Cannot find a PID file ${PID_FILE}. Are you sure the application is running?"
        fi
}

# ----------------------------------
# Application status
# ----------------------------------

application_status() {
        if [ -f ${PID_FILE} ]
        then
                PID=`head -1 ${PID_FILE}`
                RUNNING=`$PS ax | grep ${PID} | grep -v grep | wc -l`;
                if [ $RUNNING -ne 0 ]
                then
                        echo "${APP_NAME} is still running with ${PID}."
                        return 0
                else
                        echo "${APP_NAME} is not running."
                        return 2
                fi
        else
                echo "${APP_NAME} is NOT Running."
                return 1
        fi
}

# ----------------------------------
# Input options
# ----------------------------------

while getopts ":m:a:" optname
        do
        case "$optname" in
                "a")
                        APP_ARGS=${OPTARG}
                ;;
                "m")
                        MULTIOPCO=true
                ;;
                "?")
                        echo "Unknown option: ${OPTARG}"
                        print_usage
                ;;
                ":")
                        echo "Missing argument for option: ${OPTARG}"
                        print_usage
                ;;
                *)
                        print_usage
                ;;
        esac
done


COMMAND=${@:$OPTIND}

case "${COMMAND}" in
        "start")
                show_startup_settings
                echo "Startup requested."
                application_start
        ;;
        "stop")
                show_startup_settings
                echo "Shutdown requested."
                application_stop
        ;;
        "restart")
                show_startup_settings
                echo "Restart requested."
                application_stop
                application_start
        ;;
        "status")
                echo "Checking if application is up."
                application_status
        ;;
        *)
                echo "No or unknown command specified: ${COMMAND}"
                print_usage
        ;;
esac
