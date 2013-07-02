#!/bin/bash

# To Build: http://mageec.org/wiki/Building_MILEPOST

BASE_DIR=~/tools/ctuning-cc-2.5-gcc-4.4.4-ici-2.05-milepost-2.1
WORKING_DIR=$PWD

#pathadd function source:
#http://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there
pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="$1:${PATH:+"$PATH"}"
    fi
}

# Check php is installed
command -v php > /dev/null 2>&1 || { echo >&2 "PHP not installed"; exit 1; }

# (EDITED) _set_environment_for_analyis_compiler__milepost_gcc.sh
BUILD_EXT=install
BUILD_DIR=$BASE_DIR/$BUILD_EXT
PWD_SAVE=PWD

pathadd $BUILD_DIR/bin
pathadd $BASE_DIR/ccc-framework/src-plat-indep/plugins
export LD_LIBRARY_PATH=$BUILD_DIR/lib:$BUILD_DIR/lib64:$LD_LIBRARY_PATH

#set MILEPOST compiler names (in the future it may be some other compiler
#that supports ICI and plugins)
export CTUNING_ANALYSIS_CC=gcc
export CTUNING_ANALYSIS_CPP=g++
export CTUNING_ANALYSIS_FORTRAN=gfortran

#ICI PLUGINS
export ICI2_PLUGIN_VER=gcc-plugin-ici2
export ICI_LIB=$BUILD_DIR/lib
export ICI_PLUGIN_VER=$ICI2_PLUGIN_VER

export CCC_ICI_USE=ICI_USE
export CCC_ICI_PLUGINS=ICI_PLUGIN

export CCC_ICI_PASSES_FN=ici_passes_function
export CCC_ICI_PASSES_EXT=.txt

#export CCC_ICI_PASSES_RECORD_PLUGIN=$ICI_LIB/$ICI_PLUGIN_VER-save-executed-passes.so
export CCC_ICI_PASSES_RECORD_PLUGIN=$ICI_LIB/$ICI_PLUGIN_VER-extract-program-structure.so
export CCC_ICI_FEATURES_ST_FN=ici_features_function
export CCC_ICI_FEATURES_ST_EXT=.ft
export CCC_ICI_FEATURES_ST_EXTRACT_PLUGIN=$ICI_LIB/$ICI_PLUGIN_VER-extract-program-static-features.so

export ICI_PROG_FEAT_PASS=fre

export ML_ST_FEAT_TOOL=$BUILD_DIR/bin/featlstn.P
export XSB_DIR="$BUILD_DIR/3.2"
export ICI_PROG_FEAT_EXT_TOOL=$BUILD_DIR/bin/ml-feat-proc

export CCC_ROOT=$BASE_DIR/ccc-framework

export CCC_PLUGINS=$CCC_ROOT/src-plat-indep/
export PATH=$CCC_ROOT/src-plat-indep/plugins:$PATH

export CCC_UUID=uuidgen
# End of _set_environment_for_analysis_compiler__milepost_gcc.sh

# Check CCC_UUID is correctly set
if [ ! $(command -v $CCC_UUID) ]; then
    if [ $(command -v uuidgen) ]; then
        UUID_COMMAND=uuidgen
    elif [ $(command -v uuid) ]; then
        UUID_COMMAND=uuid
    fi

    if [ -z $UUID_COMMAND ]; then
        echo 'Cannot find a valid uuid generator'
        echo 'Please install one or correctly set CCC_UUID in this script'
        exit 1
    else
        echo "Setting CCC_UUID to $UUID_COMMAND"
        echo 'This should also be changed in this script'
        export CCC_UUID=$UUID_COMMAND
    fi
fi

# (EDITED) ___common_environment.sh
export ICI_PLUGIN_VERBOSE=1
export ICI_VERBOSE=1
export ICI_PROG_FEAT_PASS=fre

#set cTuning web-service parameters
export CCC_CTS_URL=cTuning.org/wiki/index.php/Special:CDatabase?request=
#export CCC_CTS_URL=localhost/cTuning/wiki/index.php/Special:CDatabase?request=
export CCC_CTS_DB=fursinne_coptcasestest
#set cTuning username (self-register at http://cTuning.org/wiki/index.php/Special:UserLogin)
#export CCC_CTS_USER=gfursin

#set user compiler (currently gcc, but can be used with any other
# compiler such as LLVM, ICC, XL, ROSE, Open64, etc)
export CTUNING_COMPILER_CC=gcc
export CTUNING_COMPILER_CPP=g++
export CTUNING_COMPILER_FORTRAN=gfortran

#misc parameters - don't change unless you understand what you do!

#compiler which was used to extract features for all programs to keep at cTuning.org
#do not change it unless you understand what you do ;) ...
export CCC_COMPILER_FEATURES_ID=129504539516446542

#use architecture flags from cTuning
export CCC_OPT_ARCH_USE=0

#retrieve opt cases only when execution time > TIME_THRESHOLD
export TIME_THRESHOLD=0.3

#retrieve opt cases only with specific notes
#export NOTES=

#retrieve opt cases only when profile info is !=""
#export PG_USE=1

#retrieve opt cases only when execution output is correct (or not if =0)
export OUTPUT_CORRECT=1

#check user or total execution time
#export RUN_TIME=RUN_TIME_USER
export RUN_TIME=RUN_TIME

#Sort optimization case by speedup (0 - ex. time, 1 - code size, 2 - comp time)
export SORT=012

echo "SORT is set to $SORT"
echo "0 - ex. time, 1 - code size, 2 - comp time"
echo "Change? (y/N)"
read -e ANSWER
if [ "$ANSWER" == 'y' ]; then
    echo "What should SORT be changed to?"
    read -e SORT
fi

#produce additional optimization report including optimization space froniters
export CT_OPT_REPORT=1

#Produce optimization space frontier
#export DIM=01 (2D frontier)
#export DIM=02 (2D frontier)
#export DIM=12 (2D frontier)
#export DIM=012 (3D frontier)
#export DIM=012

#Cut cases when producing frontier (select cases when speedup 0,1 or 2 is more than some threshold)
#export CUT=0,0,1.2
#export CUT=1,0.80,1
#export CUT=0,0,1

#TODO: Change
#find similar cases from the following platform
export CCC_PLATFORM_ID=2111574609159278179
export CCC_ENVIRONMENT_ID=2781195477254972989
export CCC_COMPILER_ID=331350613878705696

export ICI_FILE_SELECT_FUNCTIONS=$PWD/_ctuning_select_functions.txt
while [ ! -f "$ICI_FILE_SELECT_FUNCTIONS" ]; do
    echo "Cannot find a list of functions to select program features from"
    echo "Would you like to specify the location of a list? (y/N)"
    read -e ANSWER

    if [ "$ANSWER" == 'y' ]; then
        echo "Enter file location:"
        read -e ICI_FILE_SELECT_FUNCTIONS
    else
        export ICI_FILE_SELECT_FUNCTIONS=
        break
    fi
done

export CTUNING_ANALYSIS_OPT_LEVEL=-O1

export ICI_FILE_REMOVE_OPT_FLAGS=$PWD/_ctuning_remove_opt_flags.txt
while [ ! -f "$ICI_FILE_REMOVE_OPT_FLAGS" ]; do
    echo "Cannot find a list of optimization flags to remove"
    echo "Would you like to specify the location of a list? (y/N)"
    read -e ANSWER

    if [ "$ANSWER" == 'y' ]; then
        echo "Enter file location:"
        read -e ICI_FILE_REMOVE_OPT_FLAGS
    else
        export ICI_FILE_REMOVE_OPT_FLAGS=
        break
    fi
done

# __clean.sh
# Clean up the directory from previous compiles
rm -f *.tmp
rm -f ici*
rm -f *.P
rm -f *.xwam
rm -f a.out
rm -f _ctuning_program_structure.txt
# End of __clean.sh

read -p    "Enter cTuning.org username: " USER
export CCC_CTS_USER=$USER
read -s -p "Enter cTuning.org password: " PASS
export CCC_CTS_PASS=$PASS
echo ""

$@ || { echo "Failed!"; exit 1; }
echo "Finished!"
