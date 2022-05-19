#!/bin/bash

until host ${1} &> /dev/null
do
  echo "Waiting for environment..."
  sleep 20
done

echo "## Running .bash_alias and .vimrc import"
sh /Users/noelchiasson/bin/transfer_bash_vim.sh ${1}

echo "## Running import of CSV Test Files"
sh /Users/noelchiasson/bin/import_data_aws.sh ${1}

echo "## ssh-ing into environment"
if [[ ${2} == "tail" ]]
  then
    # Old way - ssh -t ${1} 'tail -f /var/log/cloud-init-output.log; bash -l'
    ssh -t ${1} 'until pgrep -x puppet &> /dev/null ; do echo "Waiting for Puppet process to exist..." ; sleep 10 ; done ; tail --pid=$(pgrep -x puppet) -f /var/log/cloud-init-output.log; bash -l'
  else
    ssh ${1}
fi
