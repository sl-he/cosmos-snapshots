#!/bin/bash
CHAIN_ID="akashnet-1"
SNAP_PATH="/root/akash/akash"
LOG_PATH="/root/akash/akash_log.txt"
DATA_PATH="/root/.akashd/data/"
SERVICE_NAME="akash.service"
SNAP_NAME=$(echo "${CHAIN_ID}_$(date '+%Y-%m-%d').tar")
OLD_SNAP=$(ls ${SNAP_PATH} | egrep -o "${CHAIN_ID}.*tar")


now_date() {
    echo -n $(TZ=":Europe/Moscow" date '+%Y-%m-%d_%H:%M:%S')
}


log_this() {
    YEL='\033[1;33m' # yellow
    NC='\033[0m'     # No Color
    local logging="$@"
    printf "|$(now_date)| $logging\n" | tee -a ${LOG_PATH}
}


log_this "Stopping ${SERVICE_NAME}"
systemctl stop ${SERVICE_NAME}; echo $? >> ${LOG_PATH}

log_this "Creating new snapshot"
time tar cf ${HOME}/${SNAP_NAME} -C ${DATA_PATH} . &>>${LOG_PATH}

log_this "Starting ${SERVICE_NAME}"
systemctl start ${SERVICE_NAME}; echo $? >> ${LOG_PATH}

log_this "Removing old snapshot(s):"
cd ${SNAP_PATH}
rm -fv ${OLD_SNAP} &>>${LOG_PATH}

log_this "Moving new snapshot to ${SNAP_PATH}"
mv ${HOME}/${CHAIN_ID}*tar ${SNAP_PATH} &>>${LOG_PATH}


du -hs ${SNAP_PATH} | tee -a ${LOG_PATH}

log_this "Done\n---------------------------\n"
