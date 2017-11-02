#!/bin/bash

# created by Brian Wray, 14-Sep-2017
# This is a script which takes a json file, extracts info, makes directories, and downloads files from The Cancer Genome Atlas (tcga)
# First, go to tcga's data portal and find the set of files you want to download. If you're trying to download < 10000 files then you
# can just use e utility that the website provides. For > 10000 files, use this script.
#
# To run this script from working directory: bach tcgaDownload.sh fileName.json dlType
# dlType can be either "normal" or "cancer". The only difference between the two is that the "normal" directories
# have a "_normal" at the end.

# Suggested, but not necessary: arrange the columns of your search results so that they only contain the project_id and the UUID.
# Next, download the json file to the working dir. 
# This script will read through the .json. It will make a directory for each project mentioned in the file, then download the file
# specified with the UUID into the proper directory. 

jsonFile=$1
dlType=$2
goodToGo=true

if [[ $dlType != "normal" ]] && [[ $dlType != "cancer" ]]; then
  goodToGo=false
  echo "Please only enter normal or cancer as the type. They're case sensitive, btw."
fi

dir=$PWD
dirStub=$dir/data/
echo -n "dirStub = "
echo $dirStub

if [[ $goodToGo == true ]]; then
  while read line
  do
	  # First, get the project name and then make a directory for it, if one isn't made already
	  if [[ $line == *"project_id"* ]]; then
		  # I can't figure out why my initial sed command isn't removing the final double-quote. Oh well.
		  dir=$(echo $line | sed 's/\"project_id\":\ \"*\"//')
      if [[ $dlType == "normal" ]]; then
		    dir=$(echo $dir | sed 's/\"/_normal\//')
      elif [[ $dlType == "cancer" ]]; then
		    dir=$(echo $dir | sed 's/\"/\//')
      fi

		  dir=${dir}
      mkdir -p $dirStub${dir}
      cd $dirStub${dir}
	  fi

	
	  # Next, download the file into the proper directory.
    if [[ $line == *"file_id"* ]]; then
      UUID=$(echo $line | sed 's/\"file_id\":\ \"*\"//')
      UUID=$(echo $UUID | sed 's/\"//')
 	    ~/gdc-client download ${UUID}
      echo -n "UUID = "
      echo ${UUID}
    fi
  done <$dir/$jsonFile
fi
