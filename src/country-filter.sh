#!/usr/bin/env bash

# ---------------------------------------------------------------------------------------- #
# Description                                                                              #
# ---------------------------------------------------------------------------------------- #
# A simple script which will implement country level blocking via TCP Wrappers. It depends #
# on geoiplookup which will return the country details for a given IP address. It will     #
# then use the default 'ACTION' to decide wether to deny or approve the connection.        #
#                                                                                          #
# Action:                                                                                  #
#     ALLOW: Only allow connections from specified countries.                              #
#     DENY: Deny all connections from specified countries.                                 #
# ---------------------------------------------------------------------------------------- #
# TCP Wrapper config:                                                                      #
#                                                                                          #
# /etc/hosts.allow                                                                         #
#      sshd: ALL: aclexec /usr/sbin/county-filter %a                                       #
#                                                                                          #
# /etc/hosts.deny                                                                          #
#      sshd: ALL                                                                           #
# ---------------------------------------------------------------------------------------- #

# space-separated list of country codes
COUNTRIES=''

# Allow or Deny countries listed
ACTION='DENY'

# ---------------------------------------------------------------------------------------- #
# In terminal                                                                              #
# ---------------------------------------------------------------------------------------- #
# A simple wrapper to check if the script is being run in a terminal or not.               #
# ---------------------------------------------------------------------------------------- #
function in_terminal
{
    [[ -t 1 ]] && return 0 || return 1;
}

# ---------------------------------------------------------------------------------------- #
# Debug                                                                                    #
# ---------------------------------------------------------------------------------------- #
# Show output only if we are running in a terminal.                                        #
# ---------------------------------------------------------------------------------------- #
function debug()
{
    local message="${1:-}"

    if [[ -n "${message}" ]]; then
        if in_terminal; then
            echo "${message}"
        fi
        logger "${message}"
    fi
}

# ---------------------------------------------------------------------------------------- #
# Check results                                                                            #
# ---------------------------------------------------------------------------------------- #
# A wrapper to check individual results against a given array and deny as required.        #
# ---------------------------------------------------------------------------------------- #
function check_results()
{
    local item=$1
    local list=$2

    #
    # Check the current item and list and decide what action to take
    #
    if [[ "${ACTION}" == 'DENY' ]]; then
        [[ $list =~ $item ]] && RESPONSE="DENY" || RESPONSE="ALLOW"
    else
        [[ $list =~ $item ]] && RESPONSE="ALLOW" || RESPONSE="DENY"
    fi

    if [[ $RESPONSE = "DENY" ]]; then
        debug "$RESPONSE sshd connection from ${IP} ($item)"
        exit 1
    fi

    #
    # Default (REPONSE=ALLOW) is to do nothing
    #
}

# ---------------------------------------------------------------------------------------- #
# Handle country blocks                                                                    #
# ---------------------------------------------------------------------------------------- #
# Lookup the country for a given IP, it should only have, at most, one entry, capture the  #
# country code and test each it to ensure it is not bocked.                                #
# ---------------------------------------------------------------------------------------- #
function handle_country_blocks
{
    #
    # Local variables
    #
    local GEOLOOKUP
    local VERSION
    local v6_regex='^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$'

    #
    # Workout if the IP is a V6 address or not
    #
    if [[ ${IP} =~ $v6_regex ]]; then
        GEOLOOKUP=$(command -v geoiplookup6)
        VERSION=6
    else
        GEOLOOKUP=$(command -v geoiplookup)
    fi

    #
    # Do the lookup and let check_results handle the blocking
    #
    if [[ -z "${GEOLOOKUP}" ]]; then
        debug "geoiplookup${VERSION} is not installed - Skipping"
    else
        COUNTRY=$("${GEOLOOKUP}" "${IP}" | awk -F ": " '{ print $2 }' | awk -F "," '{ print $1 }' | head -n 1)

        if [[ "${COUNTRY}" == 'IP Address not found' ]]; then
            COUNTRY='--'
        fi

        check_results "${COUNTRY}" "${COUNTRIES}"
    fi
}

# ---------------------------------------------------------------------------------------- #
# Main()                                                                                   #
# ---------------------------------------------------------------------------------------- #
# The main function where all of the heavy lifting and script config is done.              #
# ---------------------------------------------------------------------------------------- #
function main()
{
    #
    # NO IP given - error and abort
    #
    if [[ $# -ne 1 ]]; then
        debug 'Ip addressed not supplied - Aborting'
        exit 0
    fi

    #
    # Set a variable (Could pass it at function call)
    #
    declare -g IP="${1}"

    #
    # Turn off case sensitivity
    #
    shopt -s nocasematch

    #
    # Country level blocking
    #
    handle_country_blocks

    # Default allow
    exit 0
}

# ---------------------------------------------------------------------------------------- #
# Main()                                                                                   #
# ---------------------------------------------------------------------------------------- #
# The actual 'script' and the functions/sub routines are called in order.                  #
# ---------------------------------------------------------------------------------------- #
main "${@}"

# ---------------------------------------------------------------------------------------- #
# End of Script                                                                            #
# ---------------------------------------------------------------------------------------- #
# This is the end - nothing more to see here.                                              #
# ---------------------------------------------------------------------------------------- #
