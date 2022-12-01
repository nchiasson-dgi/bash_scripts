#!/bin/zsh

#if [ -z "$SUDO_COMMAND" ]
#  then
#    echo -e "Only root can run this script.\nRelaunching script with sudo.\n"
#    sudo -E $0 $*
#    exit 0
#fi

while getopts u:a:hr flag
do
    case "${flag}" in
        r)
          git remote set-url origin git@github.com:discoverygarden/${repository}
          echo "Redirected origin back to discoverygarden repo"
          exit;;
        u) contributor=${OPTARG};;
        h)
          echo "Add specified fork to local git repository remotes. Defaults to noel"
          echo
          echo "Syntax: ${0##*/} [-u|h]"
          echo "Options:"
          echo "  -u     User to account to target. Available: noel, morgan, chris, jordan, alex, jojo, adam."
          echo "  -a     Add all currently available remotes.(Not currently available)"
          echo "  -r     Redirects origin remote target to discoverygarden repo."
          echo "  -h     Print this help."
          exit;;
        \?)
          echo "Error: Invalid Option"
          exit;;
    esac
done

# Get the current git repo plus .git (eg. drupal-project.git)
repository=$(basename $(git remote get-url origin))
# Declaring associative array of known repos
declare -A gitrepos=( [noel]=nchiasson-dgi [morgan]=morgandawe [chris]=chrismacdonaldw [jordan]=jordandukart [alex]=alexander-cairns [jojo]=jojoves [adam]=adam-vessey )

# Set contributor default if not specified.
if [[ -z $contributor ]]
  then
    contributor="noel"
fi

# Check if contributor key exists
if [[ ${gitrepos[${contributor}]+_} ]]
  then
    # Check that the remote is not currently set
    if [[ $(git remote | grep ${contributor}) ]]
      then
        echo "Remote for '${contributor}' already configured"
      else
        git remote add ${contributor} git@github.com:${gitrepos[${contributor}]}/${repository}
        echo "Remote '${contributor}' set"
    fi
  else
    echo "'${contributor}' not found."
fi
