#! /bin/bash

#
# Ensure the defined variables are loaded in our context
#
source "../set_variables.sh"


#
# First we will get the list of all servers and focus on their names and current status.
# After that we will start those that are stopped.
# We will check that all are running.
# Finally we will stop all servers.
# 

printf "Getting the list of servers...\n"
ALL_SERVERS=$(curl -s -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/servers?fields=serverName,isActive" -H "accept: application/json" -H "Content-Type: application/json")
NUMBER_OF_SERVERS=$(echo "${ALL_SERVERS}" | jq '.result | length')

printf "Found %s servers\n" "${NUMBER_OF_SERVERS}"

for i in $(seq 0 $((${NUMBER_OF_SERVERS} - 1))); do
    NAME=$(echo "${ALL_SERVERS}" | jq -r ".result[$i].serverName")
    IS_ACTIVE=$(echo "${ALL_SERVERS}" | jq -r ".result[$i].isActive")
    printf "Server: %s is %s\n" "${NAME}" "running"
    if [ "${IS_ACTIVE}" == "false" ]; then
        printf "Starting server %s...\n" "${NAME}"
        curl -k -u "${USER}:${PWD}" -X "POST" "https://${SERVER}:${PORT}/api/v2.0/servers/operations?serverName=${NAME}&operation=start" -H "accept: application/json" -H "Content-Type: application/json"
    fi
done

# 
# As you may see from the output, some servers cannot be started unless the respective daemons are running.
# As a next step, let's check the status of all daemons and start those that are not started yet.
# Then we will repeat the steps from above.
# As we will have a repetitive operations, we will use a functiion to reuse the code.
# 

function start_daemon {
    DAEMON_STATUS=$1
    DAEMON_NAME=$2
    if [ "${DAEMON_STATUS}" == "\"Not running\"" ]; then
        printf "Starting daemon ${DAEMON_NAME}...\n"
        curl -k -u "${USER}:${PWD}" -X "POST" "https://${SERVER}:${PORT}/api/v2.0/daemons/operations?operation=start&daemon=${DAEMON_NAME}" -H "accept: application/json" -H "Content-Type: application/json"
    else
        printf "Daemon ${DAEMON_NAME} is running\n"
    fi
}

printf "Getting the list of daemons...\n"
ALL_DAEMONS=$(curl -s -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/daemons" -H "accept: application/json" -H "Content-Type: application/json")
echo "${ALL_DAEMONS}"

start_daemon "$(echo ${ALL_DAEMONS} | jq '.sshStatus')" "ssh"
start_daemon "$(echo ${ALL_DAEMONS} | jq '.as2Status')" "as2"
start_daemon "$(echo ${ALL_DAEMONS} | jq '.pesitStatus')" "pesit"
start_daemon "$(echo ${ALL_DAEMONS} | jq '.ftpStatus')" "ftp"
start_daemon "$(echo ${ALL_DAEMONS} | jq '.httpStatus')" "http"


# 
# Now you can repeat the steps from above to start the servers.
# In case you reach other issues, like not enabled services within the daemons - check the schema in swagger. 
#