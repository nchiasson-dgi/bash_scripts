#!/bin/bash

print_help() {
  cat <<-HELP
This script is to run an XSLT transform process on all MODS files within the current working directory.

The following arguments are provided:
  --transform [The XSL Transform file to use] - REQUIRED
  --dryrun [Whether to perform a dryrun or not] - Default(FALSE)

example: run_transform.sh --dryrun
HELP
exit 0
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --transform=*)
      TRANSFORM="${1#*=}"
      ;;
    --dryrun)
      DRYRUN=true
      ;;
    --help)
      print_help
      ;;
    *)
      printf "************************************************************\n"
      printf "* Error: Invalid argument, run --help for valid arguments. *\n"
      printf "************************************************************\n"
      exit 1
  esac
  shift
done

if [ -z "${TRANSFORM}" ]; then
  printf "***********************************************\n"
  printf "* Error: A transform to process is required.  *\n"
  printf "***********************************************\n"
  exit 1
fi;

#This doesn't work right yet, needs more development time
if ! command -v saxonb-xslt &> /dev/null; then
  printf "***********************************************\n"
  printf "* Error: saxonb-xslt not found.               *\n"
  printf "* Run: sudo apt-get install libsaxonb-java -Y *\n"
  printf "***********************************************\n"
  exit 1;
fi;

if [ "$DRYRUN" = true ]; then
  echo "Running dryrun..."
  for file in *.xml; do echo "saxonb-xslt -s ${file} -xsl ${TRANSFORM} > output/${file%.*}-output.xml 2>&1" ; done
  exit 0;
fi

mkdir -p output
for file in *.xml ; do saxonb-xslt -s ${file} -xsl ${TRANSFORM} > output/${file%.*}-output.xml 2>&1 ; done
echo "Command successfully ran."
exit 0
