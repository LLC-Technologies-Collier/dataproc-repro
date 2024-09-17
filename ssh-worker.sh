#!/bin/bash
#
# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS-IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
source env.sh

worker_num="$1"

WORKER_HOSTNAME="${CLUSTER_NAME}-w"
if [[ -n "$worker_num" ]]; then
  echo "worker_num: $worker_num"
  WORKER_HOSTNAME="${WORKER_HOSTNAME}-${worker_num}"
else
  WORKER_HOSTNAME="${WORKER_HOSTNAME}-0"  
fi

gcloud compute ssh --zone ${ZONE} ${WORKER_HOSTNAME}  --tunnel-through-iap --project ${PROJECT_ID}
