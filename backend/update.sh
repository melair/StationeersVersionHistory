#!/bin/bash

# Enable RVM.
source ~/.rvm/scripts/rvm

# We need to have a base directory before we can continue, given this runs from
# cron it needs to be explicitly set.
if [ -z "$BASEDIR" ]; then
    echo "Set BASEDIR environmental variable."
    exit 1
fi

# Need our steam username.
if [ -z "$STEAMUSER" ]; then
  echo "Set STEAMUSER environmental variable."
  exit 1
fi

# Need the S3 bucket name for data.
if [ -z "$S3BUCKET" ]; then
  echo "Set S3BUCKET environmental variable."
  exit 1
fi

# Need the CloudFront distrbution to issue invalidation.
if [ -z "$CLOUDFRONTID" ]; then
  echo "Set CLOUDFRONTID environmental variable."
  exit 1
fi

# Construct directories to use.
DEPOTDIR=$BASEDIR/depot
OUTPUTDIR=$BASEDIR/output
SRCDIR=$BASEDIR/src/backend
TOOLSDIR=$BASEDIR/tools

# Make working directories.
mkdir -p $OUTPUTDIR
mkdir -p $DEPOTDIR

# Change working directory to $BASEDIR as DepotDownloader stores credentials
# in working directory.
cd $BASEDIR

# Download files.
mono $TOOLSDIR/depotdownloader/DepotDownloader.exe -app 544550 -beta public -username $STEAMUSER -remember-password -all-platforms -filelist $SRCDIR/filelist.txt -dir $DEPOTDIR/public/
mono $TOOLSDIR/depotdownloader/DepotDownloader.exe -app 544550 -beta beta -username $STEAMUSER -remember-password -all-platforms -filelist $SRCDIR/filelist.txt -dir $DEPOTDIR/beta/

# Prepare Output.
VERSIONFILE=rocketstation_Data/StreamingAssets/version.ini

# Process raw Stantioneers version info.
ruby $SRCDIR/parse.rb $DEPOTDIR/public/$VERSIONFILE > $OUTPUTDIR/public.json
ruby $SRCDIR/parse.rb $DEPOTDIR/beta/$VERSIONFILE > $OUTPUTDIR/beta.json

# Merge indvidiual branches into one file.
ruby $SRCDIR/version_db.rb $OUTPUTDIR/public.json $OUTPUTDIR/version.json public
ruby $SRCDIR/version_db.rb $OUTPUTDIR/beta.json $OUTPUTDIR/version.json beta

# Generate ATOM feeds.
ruby $SRCDIR/atom.rb $OUTPUTDIR/version.json public > $OUTPUTDIR/public.atom
ruby $SRCDIR/atom.rb $OUTPUTDIR/version.json beta > $OUTPUTDIR/beta.atom

# Prepare output.
cd $OUTPUTDIR

# If the output directory is not a git repo, make it so.
if [ ! -d .git ]; then
  git init
fi

# If there are any content changes to files in output, then commit them to git
# and start the process of uploading and invalidating CloudFront. Putting
# CloudFront infront of S3 reduces bandwidth costs.
if [ -n "$(git status --porcelain)" ]; then
  Add to git.
  git add .
  git commit -am "Polled update changes."

  # Push new files to S3.
  aws s3 sync . s3://$S3BUCKET

  # Issue an invalidation for all paths within CloudFront, providing we do this
  # less then 1000 times a month this is free, after that it's $0.005/invalidation.
  aws cloudfront create-invalidation --distribution-id=$CLOUDFRONTID --paths="/*"
fi
