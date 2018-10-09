#! /bin/bash
#------------------------------------------------------------------
#
# Name: expand_jsonnet.sh
#
# Purpose: Expand a jsonnet file to json format.
#
# Usage:
#
# expand_jsonnet.sh [options] <jsonnet-file>
#
# Options:
#
# -h|--help - Print help message.
# --data    - Use data parameters.
# --mc      - Use mc parameters.
#
# Notes:
#
# 1.  The input jsonnet file can be specified as an absolute or 
#     relative path, or it can be any file underneath $UBOONEDATA_DIR.
#
#------------------------------------------------------------------
# Help function.

function dohelp {
   awk '/^# Usage/,/^# Notes:/{print $0}' $0 | cut -c3- | head -n -2
}

# Parse arguments.

jfile=''
data=0
mc=0
opt=''
while [ $# -gt 0 ]; do
  case "$1" in

    # Help.
    -h|--help )
      dohelp
      exit
      ;;

    # Data flag.
    --data )
      data=1
      opt=' -V raw_input_label=daq -V reality=data -V epoch=dynamic'
      ;;

    # MC flag.
    --mc )
      mc=1
      opt=' -V raw_input_label=driftWC:orig -V reality=sim -V perfect'
      ;;

    # Other options.

    -* )
      echo "Unknown option $1"
      exit 1
      ;;

    # Full diff flag.

    * )
      if [ x$jfile = x ]; then
        jfile=$1
      else
        echo "Too many arguments."
        exit 1
      fi
      ;;

  esac
  shift

done

# Check data and mc flags.

if [ $data -ne 0 -a $mc -ne 0 ]; then
  echo "Can not specify both --data and --mc."
  exit 1
fi
if [ $data -eq 0 -a $mc -eq 0 ]; then
  echo "Must specify one of --data or --mc."
  exit 1
fi

# Make sure $UBOONEDATA_DIR is defined and exists.

if [ x$UBOONEDATA_DIR = x ]; then
  echo "Environment variable UBOONEDATA_DIR is not defined."
  exit 1
fi
if [ ! -d $UBOONEDATA_DIR ]; then
  echo "Directory $UBOONEDATA_DIR does not exist."
  exit 1
fi

# Find input file.

jpath=''
if [ -f $jfile ]; then
  jpath=$jfile
else
  jpath=`find $UBOONEDATA_DIR -name $jfile -print | head -1`
fi
if [ x$jpath = x ]; then
  echo "No input file found."
  exit
fi
if [ ! -f $jpath ]; then
  echo "Input file $jpath does not exist."
  exit 1
fi

# Invoke jsonnet

jsonnet -J $UBOONEDATA_DIR/WireCellData \
  -J $UBOONEDATA_DIR/WireCellData/pgrapher/experiment/uboone \
  $opt \
  $jpath
