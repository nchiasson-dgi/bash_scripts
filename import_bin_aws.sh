#!/bin/bash

import_bin_aws () {
  ssh ${1} 'mkdir -p bin'
  scp -r ~/bin/*.sh "${1}:/home/ubuntu/bin"
  echo "Import finished."
}

import_bin_aws $1
