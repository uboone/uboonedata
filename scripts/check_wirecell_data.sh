#! /bin/bash
#------------------------------------------------------------------
#
# Name: check_wirecell_data.sh
#
# Purpose: Check and compare files in wire-cell-cfg and wire-cell-data
#          against uboonedata/WireCellData.  Optionally update data
#          in uboonedata.
#
# Options:
#
# -h|--help - Print help message.
# -u        - Update data in uboonedata.
# -g        - Check out and/or git pull wire-cell-cfg and wire-cell-data.
# -d        - Print full diffs (default is to just print which files differ).
#
#
#------------------------------------------------------------------

# Help function.

function dohelp {
  echo "Usage: check_wirecell_data.sh [-h|--help] [-u] [-g] [-d]"
}

# Parse arguments.

update=0
git=0
diffopt='-q'

while [ $# -gt 0 ]; do
  case "$1" in

    # Help.
    -h|--help )
      dohelp
      exit
      ;;

    # Update swizzled files.

    -u )
      update=1
      ;;

    # Git update wire-cell-cfg and wire-cell-data.

    -g )
      git=1
      ;;

    # Full diff flag.

    -d )
      diffopt='-u'
      ;;

  esac
  shift

done

# Check $MRB_SOURCE

if [ x$MRB_SOURCE = x ]; then
  echo "MRB_SOURCE is not defined."
  exit 1
fi
if [ ! -d $MRB_SOURCE ]; then
  echo "Directory $MRB_SOURCE does not exist."
  exit 1
fi
cd $MRB_SOURCE

# Update wire cell github packages.

if [ $git -ne 0 ]; then
  for pkg in wire-cell-cfg wire-cell-data
  do
    if [ ! -d $MRB_SOURCE/$pkg/.git ]; then
      cd $MRB_SOURCE
      echo "Checking out $pkg"
      rm -rf $pkg
      url=https://github.com/WireCell/$pkg
      git clone $url
      cd $pkg
      git checkout 0.9.x
    else
      echo "Git pulling $pkg"
      cd $MRB_SOURCE/$pkg
      git checkout 0.9.x
      git pull
    fi
  done
fi
cd $MRB_SOURCE

# Check top level jsonnet files in wire-cell-cfg

for file in $MRB_SOURCE/wire-cell-cfg/*.jsonnet
do
  filename=`basename $file`
  #echo "Checking $filename"
  file2=$MRB_SOURCE/uboonedata/WireCellData/$filename
  if [ ! -f $file2 ]; then
    echo "$file2 does not exist."
    if [ $update -ne 0 ]; then
      echo "Copying."
      cp $file $file2
    fi
  fi
  if ! diff $diffopt $file $file2; then
    #echo "Files $file and $file2 differ."
    if [ $update -ne 0 ]; then
      echo "Copying."
      cp $file $file2
    fi
  fi
done

# Check contents of wire-cell-cfg/pgrapher.

find $MRB_SOURCE/wire-cell-cfg/pgrapher -type f -print | while read file
do
  relpath=`echo $file | sed "s;$MRB_SOURCE/wire-cell-cfg/;;"`
  dir1=`dirname $relpath`
  dir2=`dirname $dir1`
  base1=`basename $dir1`
  base2=`basename $dir2`
  if [ $base2 != experiment -o $base1 = uboone ]; then
    file2=$MRB_SOURCE/uboonedata/WireCellData/$relpath
    if [ ! -f $file2 ]; then
      echo "$file2 does not exist."
      if [ $update -ne 0 ]; then
        echo "Copying."
        cp $file $file2
      fi
    fi
    if ! diff $diffopt $file $file2; then
      #echo "Files $file and $file2 differ."
      if [ $update -ne 0 ]; then
        echo "Copying."
        cp $file $file2
      fi
    fi
  fi
done

# Check top level jsonnet files in wire-cell-data.

for file in $MRB_SOURCE/wire-cell-data/microboone* $MRB_SOURCE/wire-cell-data/ub*
do
  filename=`basename $file`
  #echo "Checking $filename"
  file2=$MRB_SOURCE/uboonedata/WireCellData/$filename
  if [ ! -f $file2 ]; then
    echo "$file2 does not exist."
    if [ $update -ne 0 ]; then
      echo "Copying."
      cp $file $file2
    fi
  fi
  if ! diff $diffopt $file $file2; then
    #echo "Files $file and $file2 differ."
    if [ $update -ne 0 ]; then
      echo "Copying."
      cp $file $file2
    fi
  fi
done

# Check jsonnet files in uboonedata that don't have any corresponding file in wire-cell-cfg

find $MRB_SOURCE/uboonedata/WireCellData \( -type d -name nfspl1 -prune -false \) -o \( -type d -name simulation -prune -false \) -o -name \*.jsonnet | while read j1
do
  relpath=`echo $j1 | sed "s;$MRB_SOURCE/uboonedata/WireCellData/;;"`
  j2=$MRB_SOURCE/wire-cell-cfg/$relpath
  if [ ! -f $j2 ]; then
    echo "File $relpath exists only in uboonedata."
  fi
done
