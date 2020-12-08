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
#      sshd: ALL: aclexec /usr/sbin/ip-filter %a                                           #
#                                                                                          #
# /etc/hosts.deny                                                                          #
#      sshd: ALL                                                                           #
# ---------------------------------------------------------------------------------------- #

# space-separated list of country codes
COUNTRIES=''

# Allow or Deny countries listed
ACTION='DENY'

# Locate the paths for the commnands (if installed)
GEOIPLOOKUP=$(command -v geoiplookup)
GEOIPLOOKUP6=$(command -v geoiplookup6)

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
# Main()                                                                                   #
# ---------------------------------------------------------------------------------------- #
# The main function where all of the heavy lifting and script config is done.              #
# ---------------------------------------------------------------------------------------- #
function main()
{
    #
    # Local variables
    #
    local GEOLOOKUP
    local VERSION
    local v6_regex='^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$'

    #
    # NO IP given - error and abort
    #
    if [[ $# -ne 1 ]]; then
        debug 'Ip addressed not supplied - Aborting'
        exit 0
    fi

    #
    # Workout if the IP is a V6 address or not
    #
    if [[ ${1} =~ $v6_regex ]]; then
        GEOLOOKUP="${GEOIPLOOKUP6}"
        VERSION=6
    else
        GEOLOOKUP="${GEOIPLOOKUP}"
    fi

    #
    # geoiplookup isn't installed - error and abort
    #
    if [[ -z "${GEOLOOKUP}" ]]; then
        debug "geoiplookup${VERSION} is not installed - Aborting"
        exit 0
    fi

    #
    # Lookup the country for the IP (IP Address not found is a valid response)
    #
    COUNTRY=$("${GEOLOOKUP}" "${1}" | awk -F ": " '{ print $2 }' | awk -F "," '{ print $1 }' | head -n 1)

    #
    # Turn off case sensitivity
    #
    shopt -s nocasematch

    #
    # Actions:
    #     deny: deny anyone coming from a country that is in the list and allow everyone else
    #     allow: allow anyone coming from a country that is in the list and deny everyone else
    #
    if [[ "${ACTION}" == 'DENY' ]]; then
        [[ $COUNTRIES =~ $COUNTRY ]] && RESPONSE="DENY" || RESPONSE="ALLOW"
    else
        [[ $COUNTRIES =~ $COUNTRY ]] && RESPONSE="ALLOW" || RESPONSE="DENY"
    fi

    #
    # Reject connection
    #
    if [[ $RESPONSE = "DENY" ]]; then
        debug "$RESPONSE sshd connection from $1 ($COUNTRY)"
        exit 1
    fi

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
