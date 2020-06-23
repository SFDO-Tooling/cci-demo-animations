#!/bin/bash

# look at animation/README to know what's going on.

set -e

realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

TMPDIR=/tmp/cci-demo
RELPATH=`dirname $0`
SCRIPTDIR=`realpath $RELPATH`
REPO=`dirname $SCRIPTDIR`
OUTDIR=$REPO/build

mkdir -p $OUTDIR

### Clean up the TMPDIR
rm -rf $TMPDIR
mkdir $TMPDIR
cd $TMPDIR
cp $REPO/scripts/animation/* $TMPDIR

### Make a CCI-Food-Bank clone to use when we need to
### do things out of sight of the viewer.
###
### Note that the clone shares orgs with the new project
### so we can populate orgs "behind the back" of the 
### new project
###
git clone https://github.com/prescod/CCI-Food-Bank.git
cd CCI-Food-Bank
cci org default --unset dev
cci org scratch_delete dev
cci org scratch_delete qa
cd ..
echo "Recording script in '$TMPDIR'"

rm $OUTDIR/*.cast

asciinema rec $OUTDIR/1_setup.cast -i 2.5 -c "bash $TMPDIR/animation.sh setup_video" 
asciinema rec $OUTDIR/2_retrieve_changes.cast -i 2.5 -c "bash $TMPDIR/animation.sh retrieve_changes_video"
asciinema rec $OUTDIR/3_populate_data.cast -i 2.5 -c "bash $TMPDIR/animation.sh populate_data_video"
asciinema rec $OUTDIR/4_qa_org.cast -i 2.5 -c "bash $TMPDIR/animation.sh qa_org_video"