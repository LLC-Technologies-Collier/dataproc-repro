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

# Copy latest initialization action scripts
echo -n "copying actions to gcs bucket..."
gsutil -m cp \
       -L action-update.log \
       -r init/* gs://${BUCKET}/dataproc-initialization-actions
if [[ $? == 0 ]]; then
  echo "done"
else
  echo "fail"
  exit 1
fi

# re-create normal dataproc cluster
delete_standard_cluster
create_standard_cluster

echo "=================================="
echo "General Purpose Cluster re-created"
echo "=================================="

