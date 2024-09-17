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

master_num="$1"

MASTER_HOSTNAME="${CLUSTER_NAME}-m"
if [[ -n "$master_num" ]]; then
  echo "master_num: $master_num"
  MASTER_HOSTNAME="${MASTER_HOSTNAME}-${master_num}"
fi

gcloud compute ssh --zone ${ZONE} ${MASTER_HOSTNAME}  --tunnel-through-iap --project ${PROJECT_ID}
