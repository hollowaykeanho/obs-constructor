# OBS Constructor
This repository is about building the latest
[obs-studio](https://github.com/obsproject/obs-studio) from
source, package it using local Linux OS packager for safe
installation.

That way, one can access the latest OBS Studio on a
restrictive Linux operating system like Debian.




## Supported OS
Current working OS for this repository are:

1. Debian Buster (`amd64`)




## Getting Started
Each software sets are organized inside the `automation/`
directory where you need to enter them one by one in order
to complete the full build and installation. The sequence
would be:

1. Install `v4l2loopback` kernel module in your OS.
2. Install [OBS-Studio](automation/obs-studio/README.md).
3. Install [OBS-V4L2Sink Plugin](automation/obs-v4l2sink/README.md).

Once done, you can then go ahead and use the latest `obs-studio`
has to offers.




## To Keep or Not To Keep
Keeping the `obsProfile` builder allows you to roll future
updates easily by repeating the whole build process. It's
entirely up-to-you to fork out some storage spaces.

After all, to roll an update to an existing point release,
you just need to repeat the build process from scratch
all over again.




## Contribution Frequency
This build repository is contributed on hobby-level basis.
Hence, please **DO NOT** expect any ETA or whatsoever.
Contribution is best-effort only.




## Epilogue
Thanks and enjoy!
