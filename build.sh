#!/bin/bash

# The next line updates PATH for the Google Cloud SDK.
source '/home/slavayssiere/Code/google-cloud-sdk/path.bash.inc'

# The next line enables shell command completion for gcloud.
source '/home/slavayssiere/Code/google-cloud-sdk/completion.bash.inc'

# docker build -t gcr.io/ul-management/pegass-connector:v1 .
gcloud docker push gcr.io/ul-management/pegass-connector:v1
