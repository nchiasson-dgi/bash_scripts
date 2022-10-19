#!/bin/bash

# add some variables around retries
retryCount=0
maxRetries=15
retryCountDelay=30

# run the script as sudo so that you
#if [ -z "$SUDO_COMMAND" ]
#then
  #echo -e "Only root can run this script.\nRelaunching script with sudo.\n"
  #sudo -E $0 $*
  #exit 0
#fi

while getopts lsth flag
do
    case "${flag}" in
        l)
          LOCAL=true
        ;;
        s)
          SSH=true
        ;;
        t)
          TAIL=true
          SSH=true
        ;;
        h)
          echo "Upload .bash_alias, .vimrc, and sample data files to specified environment."
          echo
          echo "Syntax: ${0##*/} [-l|s|t|h] environment-url"
          echo "Options:"
          echo "  -l     Specify if using a local vagrant environment."
          echo "  -s     SSH into the environment after transferring files."
          echo "  -t     Start tailing /var/log/cloud-init-output.log after sshing.(Desire to SSH is assumed.)"
          echo "  -h     Print this help."
          exit;;
        \?)
          echo "Error: Invalid Option"
          exit;;
    esac
done
shift $((OPTIND - 1))

until host ${1} &> /dev/null || [ $retryCount -gt $maxRetries ]
do
  echo "Waiting for environment... ${retryCount}/${maxRetries}"
  sleep $retryCountDelay
  #sudo pkill -HUP -x mDNSResponder
  ((retryCount++))
done

echo "## Running .bash_alias and .vimrc import"
sh /Users/noelchiasson/bin/transfer_bash_vim.sh ${1}

echo "## Running import of CSV Test Files"
sh /Users/noelchiasson/bin/import_data_aws.sh ${1}

echo "## Running import of bin scripts"
sh /Users/noelchiasson/bin/import_bin_aws.sh ${1}

if [[ $SSH = true ]]
  then
    echo "## ssh-ing into environment"
    if [[ $TAIL = true ]]
      then
        ssh -t ${1} 'until pgrep -x puppet &> /dev/null ; do echo "Puppet process does not exist... retrying" ; sleep 10 ; done ; tail --pid=$(pgrep -x puppet) -f /var/log/cloud-init-output.log; bash -l'
      else
        ssh ${1}
    fi
fi
