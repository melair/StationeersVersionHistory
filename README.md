# Stationeers Version History

This repository contains the front and back end of https://stationeers.melaircraft.net.

## Frontend

The frontend is written in React, it uses as few external dependencies as possible
to attempt to reduce bloat.

To set up the development environment run:

```npm install```

To run the development environment:

```npm start```

You can then browse to:

```http://localhost:3000```

The frontend is hard coded to retrieve the live version information, other
then stationeers.melaircraft.net the only other hostname returned in CORS headers
is localhost.

## Backend

The backend is written in Ruby and depends on DepotDownloader (running in Mono
on linux). You will also need a modern version of ruby under RVM.

To run, create a directory that will contain all backend work. Such as:

```
mkdir -p ~/stationeers
```

Change into that directory and check out this repository:

```
cd ~/stationeers
git clone https://github.com/melair/StationeersVersionHistory src
```

Create a tools directory, and install depotdownloader there.

```
mkdir -p ~/stationeers/tools
cd ~/stationeers/tools
wget https://github.com/SteamRE/DepotDownloader/releases/download/DepotDownloader_2.2.2/depotdownloader-2.2.2.zip
unzip depotdownloader-2.2.2.zip
```

You will need to seed your Steam credentials into Depot Downloader.

```
cd ~/stationeers
mono depotdownloader/DepotDownloader.exe -username <STEAMUSER> -remember-password -app 544550
```

It may download some files you'll need to clean up. Once complete you should be
able to run the tool.

```
BASEDIR=~/stationeers STEAMUSER=username S3BUCKET=destinationbucket CLOUDFRONTID=cloudfrontid ~/stationeers/src/backend/update.sh
```
