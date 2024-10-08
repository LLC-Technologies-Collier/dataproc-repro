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

function enable_services () {
  # Enable Dataproc service
  set -x
  gcloud services enable \
    dataproc.googleapis.com \
    compute.googleapis.com \
    --project=${PROJECT_ID}
  set +x
}

function exists_standard_cluster() {
  set +x
  STANDARD_CLUSTER="$(gcloud dataproc clusters list --format=json)"
  JQ_CMD=".[] | select(.clusterName | test(\"${CLUSTER_NAME}$\"))"
  OUR_CLUSTER=$(echo ${STANDARD_CLUSTER} | jq -c "${JQ_CMD}")

  if [[ -z "${OUR_CLUSTER}" ]]; then
    return -1
  else
    echo "cluster exists"
    return 0
  fi
}

#    cloud-dataproc-ci.googleapis.com \ # DPMS dependency?
function create_standard_cluster() {

  if exists_standard_cluster == 0; then
    echo "standard cluster already exists"
    return 0
  fi

  set -x  

  date
  time gcloud dataproc clusters create ${CLUSTER_NAME} \
    --master-boot-disk-type           pd-ssd \
    --worker-boot-disk-type           pd-ssd \
    --secondary-worker-boot-disk-type pd-ssd \
    --single-node \
    --master-boot-disk-size 100 \
    --worker-boot-disk-size 100 \
    --secondary-worker-boot-disk-size 50 \
    --master-machine-type "${MASTER_MACHINE_TYPE}" \
    --worker-machine-type "${PRIMARY_MACHINE_TYPE}" \
    --master-accelerator "type=${MASTER_ACCELERATOR_TYPE}" \
    --worker-accelerator "type=${PRIMARY_ACCELERATOR_TYPE}" \
    --region "${REGION}" \
    --zone "${ZONE}" \
    --subnet "${SUBNET}" \
    --no-address \
    --service-account="${GSA}" \
    --tags="${TAGS}" \
    --bucket "${BUCKET}" \
    --enable-component-gateway \
    --metadata "install-gpu-agent=true" \
    --metadata "gpu-driver-provider=NVIDIA" \
    --metadata "public_secret_name=efi-db-pub-key-042" \
    --metadata "private_secret_name=efi-db-priv-key-042" \
    --metadata "secret_project=${PROJECT_ID}" \
    --metadata "secret_version=1" \
    --metadata "modulus_md5sum=d41d8cd98f00b204e9800998ecf8427e" \
    --metadata dask-runtime="yarn" \
    --metadata bigtable-instance=${BIGTABLE_INSTANCE} \
    --metadata rapids-runtime="SPARK" \
    --initialization-actions "${INIT_ACTIONS_ROOT}/gpu/install_gpu_driver.sh" \
    --initialization-action-timeout=90m \
    --metadata "bigtable-instance=${BIGTABLE_INSTANCE}" \
    --no-shielded-secure-boot \
    --image-version "${IMAGE_VERSION}" \
    --max-idle="${IDLE_TIMEOUT}" \
    --scopes 'https://www.googleapis.com/auth/cloud-platform,sql-admin'
  date
  set +x
  
}

#    --num-masters=1 \
#    --num-workers=2 \
#    --metadata cuda-version="${CUDA_VERSION}" \
#    --initialization-actions "${INIT_ACTIONS_ROOT}/gpu/install_gpu_driver.sh,${INIT_ACTIONS_ROOT}/dask/dask.sh,${INIT_ACTIONS_ROOT}/rapids/rapids.sh" \
#    --num-masters=1 \
#    --num-workers=2 \
#    --initialization-actions "${INIT_ACTIONS_ROOT}/gpu/install_gpu_driver.sh" \
#    --image "projects/cjac-2021-00/global/images/custom-2-2-debian12-2024-07-27" \
#    --image "projects/cjac-2021-00/global/images/custom-2-2-ubuntu22-2024-07-27" \
#    --image "projects/cjac-2021-00/global/images/custom-2-2-rocky9-2024-07-27" \


#    --metadata dask-runtime="standalone" \
#    --initialization-actions "${INIT_ACTIONS_ROOT}/bigtable/bigtable.sh" \
#    --worker-accelerator "type=${ACCELERATOR_TYPE}" \
#    --initialization-actions "${INIT_ACTIONS_ROOT}/gpu/install_gpu_driver.sh" \
#    --image "projects/cjac-2021-00/global/images/nvidia-open-kernel-bookworm-2024-06-26" \
#    --image-version "${IMAGE_VERSION}" \
#    --image "projects/cjac-2021-00/global/images/nvidia-open-kernel-bookworm-2024-06-21-a" \
#    --no-shielded-secure-boot \
#    --image-version "${IMAGE_VERSION}" \
#    --initialization-actions "${INIT_ACTIONS_ROOT}/gpu/install_gpu_driver.sh" \

#
# GPU
#
    # --optional-components JUPYTER,ZOOKEEPER \
    # --worker-accelerator type=${ACCELERATOR_TYPE} \
    # --master-accelerator type=${ACCELERATOR_TYPE} \
    # --metadata include-gpus=true \
    # --metadata gpu-driver-provider=NVIDIA \
    # --metadata install-gpu-agent=true \
    # --initialization-action-timeout=15m \
    # --initialization-actions ${INIT_ACTIONS_ROOT}/gpu/install_gpu_driver.sh \
    # --properties='^#^dataproc:conda.packages=ipython-sql==0.3.9,pyhive==0.6.5' \
    # --properties spark:spark.executor.resource.gpu.amount=1,spark:spark.task.resource.gpu.amount=1 \
    # --properties "presto-catalog:bigquery_my_other_project.connector.name"="bigquery" \



#    --image https://www.googleapis.com/compute/v1/projects/cloud-dataproc-ci/global/images/dataproc-2-0-debian10-20240314-212221-rc99 \
#    --initialization-actions "${INIT_ACTIONS_ROOT}/hue/hue.sh" \
#     --metadata startup-script-url="${INIT_ACTIONS_ROOT}/delay-masters-startup.sh" \
#     --scopes 'https://www.googleapis.com/auth/cloud-platform,sql-admin'

#
# DASK rapids
#
    # --metadata rapids-runtime=DASK \
    # --metadata cuda-version="${CUDA_VERSION}" \
    # --metadata rapids-version="22.04" \
    # --initialization-actions ${INIT_ACTIONS_ROOT}/gpu/install_gpu_driver.sh,${INIT_ACTIONS_ROOT}/rapids/rapids.sh \

#     --metadata ="$(perl -n -e '@l=<STDIN>; chomp @l; print join q{,}, @l' <init/dataproc.${CASE_NUMBER}.metadata)" \

#    --max-idle=${IDLE_TIMEOUT} \

# 20240724 vvv  prior ^^^

    # --initialization-actions "${INIT_ACTIONS_ROOT}/gpu/install_gpu_driver.sh" \
    # --metadata rapids-runtime="DASK" \
    # --metadata rapids-version="23.12" \
    # --metadata install-gpu-agent="true" \
    # --metadata cuda-version="${CUDA_VERSION}" \
    # --metadata "public_secret_name=efi-db-pub-key-005" \
    # --metadata "private_secret_name=efi-db-priv-key-005" \
    # --metadata "secret_project=${PROJECT_ID}" \
    # --metadata "secret_version=1" \
    # --metadata "modulus_md5sum=1bd7778c62497c257ea1cd0c766a593e" \




#
# bigtable
#
    # --initialization-actions "${INIT_ACTIONS_ROOT}/bigtable/bigtable.sh" \
    # --metadata bigtable-instance=${BIGTABLE_INSTANCE} \
    # --initialization-action-timeout=15m \

#
# Oozie
#
#    --metadata startup-script-url="${INIT_ACTIONS_ROOT}/delay-masters-startup.sh" \
#    --initialization-actions "${INIT_ACTIONS_ROOT}/oozie/oozie.sh" \
#    --properties "dataproc:dataproc.master.custom.init.actions.mode=RUN_AFTER_SERVICES" \

#
# Livy
#
#    --initialization-actions "${INIT_ACTIONS_ROOT}/livy/livy.sh" \

# complex init actions on 2.1 repro

    # --metadata startup-script-url="${INIT_ACTIONS_ROOT}/delay-masters-startup.sh" \
    # --initialization-actions "${INIT_ACTIONS_ROOT}/oozie/oozie.sh,${INIT_ACTIONS_ROOT}/bigtable/bigtable.sh,${INIT_ACTIONS_ROOT}/sqoop/sqoop.sh" \
    # --initialization-action-timeout=15m \
    # --optional-components ZOOKEEPER \
    # --metadata "hive-metastore-instance=${PROJECT_ID}:${REGION}:${HIVE_INSTANCE_NAME}" \
    # --metadata hive-cluster-name="${HIVE_CLUSTER_NAME}" \
    # --metadata bigtable-instance="${BIGTABLE_INSTANCE}" \
    # --metadata bigtable-project="${PROJECT_ID}" \
    # --properties="^~~^$(perl -n -e '@l=<STDIN>; chomp @l; print join q{~~}, @l' <init/dataproc.${CASE_NUMBER}.properties)" \
    # --scopes 'https://www.googleapis.com/auth/cloud-platform,sql-admin'

#    --enable-component-gateway \
#    --metadata startup-script-url="${INIT_ACTIONS_ROOT}/delay-masters-startup.sh" \
#    --initialization-actions "${INIT_ACTIONS_ROOT}/oozie/oozie.sh,${INIT_ACTIONS_ROOT}/bigtable/bigtable.sh,${INIT_ACTIONS_ROOT}/sqoop/sqoop.sh" \
#    --initialization-action-timeout=15m \
#    --properties "dataproc:dataproc.master.custom.init.actions.mode=RUN_AFTER_SERVICES" \
#    --initialization-action-timeout=15m \
#    --metadata bigtable-instance=${BIGTABLE_INSTANCE} \

#     --metadata startup-script-url="${INIT_ACTIONS_ROOT}/delay-masters-startup.sh" \
#     --properties "dataproc:dataproc.master.custom.init.actions.mode=RUN_AFTER_SERVICES" \

#    --initialization-actions "${INIT_ACTION_PATHS}" \
#    --initialization-actions ${INIT_ACTIONS_ROOT}/oozie/oozie.sh,${INIT_ACTIONS_ROOT}/bigtable/bigtable.sh,${INIT_ACTIONS_ROOT}/sqoop/sqoop.sh \
#    --initialization-actions ${INIT_ACTIONS_ROOT}/oozie/oozie.sh \

# [serial] new initialization action to execute in serial #1086
# https://github.com/GoogleCloudDataproc/initialization-actions/pull/1086   
#    --initialization-actions ${INIT_ACTIONS_ROOT}/serial/serial.sh \
#    --metadata "initialization-action-paths=${INIT_ACTION_PATHS}" \
#    --metadata "initialization-action-paths-separator=${PATH_SEPARATOR}" \

  
    # --worker-boot-disk-type pd-ssd \
    # --worker-boot-disk-size 50 \
    # --worker-machine-type ${MACHINE_TYPE} \
    # --num-masters=3 \
    # --num-workers=3 \


  #    --metadata spark-bigquery-connector-version=0.31.1 \

    # --worker-boot-disk-type pd-ssd \
    # --worker-boot-disk-size 50 \
    # --worker-machine-type ${MACHINE_TYPE} \
    # --num-workers=3 \

#      --single-node \


    # --no-shielded-secure-boot \
    # --worker-accelerator type=${ACCELERATOR_TYPE} \
    # --master-accelerator type=${ACCELERATOR_TYPE} \
    # --metadata include-gpus=true \
    # --metadata gpu-driver-provider=NVIDIA \
    # --initialization-action-timeout=15m \
    # --initialization-actions ${INIT_ACTIONS_ROOT}/gpu/install_gpu_driver.sh \
    # --properties spark:spark.executor.resource.gpu.amount=1,spark:spark.task.resource.gpu.amount=1 \
    # --metadata init-actions-repo=${INIT_ACTIONS_ROOT} \
    # --metadata install-gpu-agent=true \
    # --metadata cuda-version=${CUDA_VERSION} \
  
#,${INIT_ACTIONS_ROOT}/nvidia_docker.sh \
  #    --max-idle=${IDLE_TIMEOUT} \
#    --initialization-action-timeout=15m \
#    --worker-accelerator type=${ACCELERATOR_TYPE} \
#    --master-accelerator type=${ACCELERATOR_TYPE} \
  #     --metadata gpu-driver-provider=NVIDIA \
    # --initialization-actions ${INIT_ACTIONS_ROOT}/gpu/install_gpu_driver.sh \

#    --image-version 1.4.80-ubuntu18 \

  
# Increase log verbosity
#   --verbosity=debug \
  
#
# Kafka
#

#    --optional-components ZOOKEEPER \
#    --metadata "run-on-master=true" \
#    --initialization-actions gs://goog-dataproc-initialization-actions-${REGION}/kafka/kafka.sh \
  
#
# Hive
#

# tested 20240719
#    --initialization-actions "${INIT_ACTIONS_ROOT}/cloud-sql-proxy/cloud-sql-proxy.sh" \
#    --properties "hive:hive.metastore.warehouse.dir=gs://${HIVE_DATA_BUCKET}/hive-warehouse" \
#    --metadata "hive-metastore-instance=${PROJECT_ID}:${REGION}:${HIVE_INSTANCE_NAME}" \
#    --metadata "db-hive-password-uri=gs://${BUCKET}/dataproc-initialization-actions/mysql_hive_password.encrypted" \
#    --metadata "kms-key-uri=projects/cjac-2021-00/locations/global/keyRings/keyring-cluster-1668020639/cryptoKeys/kdc-root-cluster-1668020639" \



#
#    --metadata "hive-metastore-instance=${PROJECT_ID}:${REGION}:${HIVE_INSTANCE_NAME}" \
#    --metadata hive-cluster-name="${HIVE_CLUSTER_NAME}" \
#    --metadata bigtable-instance="${BIGTABLE_INSTANCE}" \
#    --metadata bigtable-project="${PROJECT_ID}" \
#    --properties="^~~^$(perl -n -e '@l=<STDIN>; chomp @l; print join q{~~}, @l' <init/dataproc.${CASE_NUMBER}.properties)" \

#    --initialization-actions gs://goog-dataproc-initialization-actions-${REGION}/cloud-sql-proxy/cloud-sql-proxy.sh \
#    --properties hive:hive.metastore.warehouse.dir=gs://${HIVE_DATA_BUCKET}/hive-warehouse \
#    --metadata "hive-metastore-instance=${PROJECT_ID}:${REGION}:${HIVE_INSTANCE_NAME}" \
#    --scopes 'https://www.googleapis.com/auth/cloud-platform,sql-admin'

#    --single-node \

#    --initialization-actions ${INIT_ACTIONS_ROOT}/cloud-sql-proxy/cloud-sql-proxy.sh \
#    --num-workers=2 \
#    --autoscaling-policy=${AUTOSCALING_POLICY_NAME} \
#    --scopes 'https://www.googleapis.com/auth/cloud-platform'
  
#
#  Cluster options
#    --optional-components FLINK \
#    --num-worker-local-ssds 4 \
#     --initialization-actions ${INIT_ACTIONS_ROOT}/fail.sh \
#    --optional-components FLINK \    

#    --optional-components JUPYTER,ZOOKEEPER \
#    --properties="^~~^$(perl -n -e '@l=<STDIN>; chomp @l; print join q{~~}, @l' <init/${CASE_NUMBER}/dataproc.properties)"
#    --initialization-actions ${INIT_ACTIONS_ROOT}/init-ab0bffe.bash \
#    --initialization-actions ${INIT_ACTIONS_ROOT}/s-agent-dm-filterer.sh \
#
#    --num-masters=3 \
#    --num-workers=2 \
#    --single-node \
#    --master-machine-type n1-standard-4 \
#    --master-boot-disk-type pd-ssd \
#    --master-boot-disk-size 50 \
#    --num-master-local-ssds 4 \
#    --worker-machine-type n1-standard-4 \
#    --worker-boot-disk-type pd-ssd \
#    --worker-boot-disk-size 200 \
#    --num-secondary-workers 2 \
#    --secondary-worker-boot-disk-size 50 \
#    --secondary-worker-boot-disk-type pd-standard \
#    --secondary-worker-type preemptible \
#    --bucket ${BUCKET} \
#    --max-idle=30m \
#    --enable-component-gateway \
#    --optional-components JUPYTER,ZOOKEEPER \
#    --properties="${PROPERTIES}" \
#    --properties="core:fs.defaultFS=gs://${BUCKET}" \
#    --properties="yarn:yarn.log-aggregation-enable=true" \
#    --properties="^~~^$(perl -n -e '@l=<STDIN>; chomp @l; print join q{~~}, @l' <init/dataproc.properties)" \
#    --properties-file=${INIT_ACTIONS_ROOT}/dataproc.properties \

#
#  Test startup scripts and init action scripts
#
#    --metadata startup-script-url="${INIT_ACTIONS_ROOT}/startup-script.pl" \
#    --metadata startup-script-url="${INIT_ACTIONS_ROOT}/startup-script.sh" \
#    --metadata startup-script-url="${INIT_ACTIONS_ROOT}/env-change.sh" \
#    --metadata ^~~^startup-script="$(cat init/startup-script.pl)" \
#    --metadata ^~~^startup-script="$(cat init/startup-script.sh)" \
#    --metadata ^~~^startup-script="$(cat init/startup-script-logsrc.sh)" \
#    --initialization-actions ${INIT_ACTIONS_ROOT}/startup-script.pl \
#    --initialization-actions ${INIT_ACTIONS_ROOT}/startup-script.sh \
#    --initialization-actions ${INIT_ACTIONS_ROOT}/sqoop/sqoop.sh \
#    --initialization-actions ${INIT_ACTIONS_ROOT}/kernel/upgrade-kernel.sh \
#    --metadata startup-script='#!/bin/bash
# echo "hello world xyz"
# ' \
#     --metadata startup-script='#!/bin/bash
# CONNECTOR_JARS=$(find / -iname "*spark-bigquery-connector*.jar")
# for jar in ${CONNECTOR_JARS}; do rm $(realpath ${jar}); done
# rm ${CONNECTOR_JARS}
#  ' \


#
# bigtable
#
#    --metadata bigtable-instance=${BIGTABLE_INSTANCE} \
#    --initialization-actions ${INIT_ACTIONS_ROOT}/bigtable/bigtable.sh \
#
#
#  Oozie
#
#    --initialization-actions ${INIT_ACTIONS_ROOT}/oozie/oozie.sh \

#
#  Conda
#
#    --properties="dataproc:conda.env.config.uri=${INIT_ACTIONS_ROOT}/environment.yaml" \
#    --single-node \
#    --properties="dataproc:dataproc.logging.stackdriver.enable=true" \
#    --properties="dataproc:dataproc.logging.stackdriver.job.driver.enable=true" \
#    --properties="dataproc:dataproc.logging.stackdriver.job.yarn.container.enable=true" \
#    --properties="dataproc:dataproc.monitoring.stackdriver.enable=true" \


#
# NVIDIA
#
#    --metadata include-gpus=true \
#    --worker-accelerator type=${ACCELERATOR_TYPE} \
#    --master-accelerator type=${ACCELERATOR_TYPE} \
#    --metadata gpu-driver-provider=NVIDIA \
#    --metadata init-actions-repo=${INIT_ACTIONS_ROOT} \
#    --metadata install-gpu-agent=true \
#    --metadata cuda-version=${CUDA_VERSION} \


#
# NVidia Docker on yarn
#
#    --metadata yarn-docker-image=${YARN_DOCKER_IMAGE} \
#    --optional-components DOCKER \
#    --initialization-actions ${INIT_ACTIONS_ROOT}/kernel/upgrade-kernel.sh \
#    --initialization-actions ${INIT_ACTIONS_ROOT}/util/upgrade-kernel.sh,${INIT_ACTIONS_ROOT}/gpu/install_gpu_driver.sh,${INIT_ACTIONS_ROOT}/nvidia_docker.sh \

#
# Presto
#
#    --optional-components PRESTO \

#
# HBase
#
#    --optional-components HBASE,ZOOKEEPER \

# Flink
#    --optional-components FLINK \
    
#
# Rapids
#
#    --metadata rapids-runtime=SPARK \
#    --metadata rapids-runtime=DASK \
#    --initialization-actions ${INIT_ACTIONS_ROOT}/spark-rapids/spark-rapids.sh \

#
# passing properties (to a job only) in a file
#
# --properties-file=${INIT_ACTIONS_ROOT}/dataproc.properties

function delete_standard_cluster() {
  set -x
  if exists_standard_cluster == 0; then
    echo "standard cluster exists"
  else
    echo "standard cluster does not exist.  Not deleting"
    set +x
    return 0
  fi

  gcloud dataproc clusters delete --quiet --region ${REGION} ${CLUSTER_NAME}
  set +x
  echo "cluster deleted"
}

DATE=$(date +%s)
function set_cluster_name() {
  cluster_name="$(jq -r .CLUSTER_NAME env.json)"

  # Only update cluster if it is not set
  if [[ -z "${cluster_name}" || "${cluster_name}" == "null"  ]]; then
    export CLUSTER_NAME="cluster-${DATE}"
  else
    echo "CLUSTER_NAME already set to [${cluster_name}]"
  fi

  cp env.json env.json.tmp
  cat env.json.tmp | jq ".CLUSTER_NAME |= \"${CLUSTER_NAME}\"" > env.json
  rm env.json.tmp
  source env.sh
}

function create_project(){
  set -x
  local PROJ_DESCRIPTION=$(gcloud projects describe ${PROJECT_ID} --format json 2>/dev/null)
  if [[ -n ${PROJ_DESCRIPTION} && "$(echo $PROJ_DESCRIPTION | jq -r .lifecycleState)" == "ACTIVE" ]]; then
    echo "project already exists!"
    return
  else
    local LCSTATE="$(echo $PROJ_DESCRIPTION | jq .lifecycleState)"
    if [[ -n ${PROJ_DESCRIPTION} && "$(echo $PROJ_DESCRIPTION | jq -r .lifecycleState)" == "DELETE_REQUESTED" ]]; then
      gcloud projects undelete --quiet ${PROJECT_ID}
    else
      gcloud projects create ${PROJECT_ID} --folder ${FOLDER_NUMBER}
    fi

    if [[ $? -ne 0 ]]; then
      echo "could not create project."
      exit -1
    fi

    local PRJBA=$(gcloud beta billing projects describe ${PROJECT_ID} --format json | jq -r .billingAccountName)

    # link project to billing account
    if [[ -z "${PRJBA}" ]]; then
      set +x
      echo "

          In order to connect a billing account with your new project, you will
          need to temporariliy grant your ${USER}@google.com account the
          roles/billing.admin role for the premium-cloud-support.com org.  After
          reviewing the documentation[1], visit the PCS Command center[2] and
          enter your justification type, justification ID and your @google.com
          email.  Select 'Other (Fill in Other Role field)' for 'Role', and
          enter 'roles/billing.admin' into the 'Other Role' field.  See the
          screenshot[3] for an example.

          Once this has been completed, prepare to log in with your @google.com
          account, and then press enter.

          [1] https://g3doc.corp.google.com/company/gfw/support/cloud/processes/new-hires/gcp-resources/premium-support-acc.md#granting-iam-roles-on-organization-iam-policy-only-when-needed
          [2] https://support-gcp-admin.googleplex.com/grantiam
          [3] https://screenshot.googleplex.com/9xUWEefmSVN2GZC

"
      read

      local active_account=$(gcloud auth list 2>/dev/null | awk '/^\*/ {print $2}')
      while [[ $active_account != "${USER}@google.com" ]]; do
        echo "AUTHENTICATE AS YOUR @google.com EMAIL ADDRESS"
        gcloud auth login ${USER}@google.com
        local active_account=$(gcloud auth list 2>/dev/null | awk '/^\*/ {print $2}')
      done

      set -x
      execute_with_retries "gcloud beta billing projects link ${PROJECT_ID} --billing-account ${BILLING_ACCOUNT}"
      set +x
      if [[ $? != 0 ]]; then
        echo "failed to link project and billing account"
        exit -1
      fi

      echo "Prepare to log in with your @premium-cloud-support.com account and then press enter..."
      read

      local active_account=$(gcloud auth list 2>/dev/null | awk '/^\*/ {print $2}')
      while [[ $active_account != "${USER}@premium-cloud-support.com" ]]; do
        echo "AUTHENTICATE AS YOUR @premium-cloud-support.com EMAIL ADDRESS"
        gcloud auth login ${USER}@premium-cloud-support.com
        local active_account=$(gcloud auth list 2>/dev/null | awk '/^\*/ {print $2}')
      done
    fi
  fi
  set +x
  echo "project created!"
}

function delete_project() {
  set -x
  local active_account=$(gcloud auth list 2>/dev/null | awk '/^\*/ {print $2}')
  while [[ $active_account != "${USER}@google.com" ]]; do
    echo "AUTHENTICATE AS YOUR @google.com EMAIL ADDRESS"
    gcloud auth login ${USER}@google.com
    local active_account=$(gcloud auth list 2>/dev/null | awk '/^\*/ {print $2}')
  done
  gcloud beta billing projects unlink ${PROJECT_ID}
  local active_account=$(gcloud auth list 2>/dev/null | awk '/^\*/ {print $2}')
  while [[ $active_account != "${USER}@premium-cloud-support.com" ]]; do
    echo "AUTHENTICATE AS YOUR @premium-cloud-support.com EMAIL ADDRESS"
    gcloud auth login ${USER}@premium-cloud-support.com
    local active_account=$(gcloud auth list 2>/dev/null | awk '/^\*/ {print $2}')
  done
  gcloud projects delete --quiet ${PROJECT_ID}
  set +x
  echo "project deleted!"
}

function configure_gcloud() {
  gcloud config set compute/region ${REGION}
  gcloud config set compute/zone ${ZONE}
  gcloud config set core/project ${PROJECT_ID}
}

function grant_kms_roles(){
  set -x

  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${GSA}" \
    --role=roles/cloudkms.cryptoKeyDecrypter \

  set +x
  echo "dpgke service account roles granted"
}

function grant_mysql_roles(){
  set -x

  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${GSA}" \
    --role=roles/cloudsql.editor \

  set +x
  echo "cloudsql service account editor role granted"
}

function create_mysql_admin_password() {
    dd if=/dev/urandom bs=8 count=4 | xxd -p | \
      gcloud kms encrypt \
      --location=global \
      --keyring=projects/cjac-2021-00/locations/global/keyRings/keyring-cluster-1668020639 \
      --key=projects/cjac-2021-00/locations/global/keyRings/keyring-cluster-1668020639/cryptoKeys/kdc-root-cluster-1668020639 \
      --plaintext-file=- \
      --ciphertext-file=init/mysql_admin_password.encrypted
}


function grant_bigtables_roles(){
  set -x

  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${GSA}" \
    --role=roles/bigtable.user \

  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${GSA}" \
    --role=roles/bigtable.admin \

  set +x
  echo "dpgke service account roles granted"
}


function create_kms_keyring() {
  set -x
  if (gcloud kms keyrings list --location global | grep ${KMS_KEYRING}); then
    echo "keyring already exists"
  else
    gcloud kms keyrings create ${KMS_KEYRING} --location=global
    echo "kms keyring created"
  fi

  set +x
}

function create_kerberos_kdc_key() {
  set -x
  if (gcloud kms keys list --location global --keyring=${KMS_KEYRING} | grep ${KDC_ROOT_PASSWD_KEY}); then
    echo "kerberos kdc key exists"
  else
    gcloud kms keys create ${KDC_ROOT_PASSWD_KEY} \
      --location=global \
      --keyring=${KMS_KEYRING} \
      --purpose=encryption
    echo "kerberos kdc key created"
  fi
  set +x
}

function create_kerberos_kdc_password() {
  set -x
  if [[ -f init/${KDC_ROOT_PASSWD_KEY}.encrypted ]]; then
    echo "password exists"
  else
    dd if=/dev/urandom bs=8 count=4 | xxd -p | \
      gcloud kms encrypt \
      --location=global \
      --keyring=${KMS_KEYRING} \
      --key=${KDC_ROOT_PASSWD_KEY} \
      --plaintext-file=- \
      --ciphertext-file=init/${KDC_ROOT_PASSWD_KEY}.encrypted
  fi
  set +x
}

function create_kerberos_sa_password() {
    dd if=/dev/urandom bs=8 count=4 | xxd -p | \
      gcloud kms encrypt \
      --location=global \
      --keyring=${KMS_KEYRING} \
      --key=${KDC_ROOT_PASSWD_KEY} \
      --plaintext-file=- \
      --ciphertext-file=init/${KDC_SA_PASSWD_KEY}.encrypted
}

function create_kdc_server() {
  # Authors: oklev@softserveinc.com
  set -x

  local METADATA="kdc-root-passwd=${INIT_ACTIONS_ROOT}/${KDC_ROOT_PASSWD_KEY}.encrypted"
  METADATA="${METADATA},kms-keyring=${KMS_KEYRING}"
  METADATA="${METADATA},kdc-root-passwd-key=${KDC_ROOT_PASSWD_KEY}"
  METADATA="${METADATA},startup-script-url=${INIT_ACTIONS_ROOT}/kdc-server.sh"
  METADATA="service-account-user=${GSA}"
  # Spin up a KDC server
  gcloud compute instances create ${KDC_NAME} \
    --zone ${ZONE} \
    --subnet ${SUBNET} \
    --service-account=${GSA} \
    --boot-disk-type pd-ssd \
    --image-family=${KDC_IMAGE_FAMILY} \
    --image-project=${KDC_IMAGE_PROJECT} \
    --machine-type=${MACHINE_TYPE} \
    --scopes='cloud-platform' \
    --hostname=${KDC_FQDN} \
    --metadata ${METADATA}
  set +x
}

function delete_kdc_server() {
  set -x
  gcloud compute instances delete ${KDC_NAME} \
    --quiet
  set +x
  echo "kdc deleted"
}

function create_kerberos_cluster() {
  # https://cloud.google.com/dataproc/docs/concepts/components/ranger#installation_steps
  set -x
  gcloud dataproc clusters create ${CLUSTER_NAME} \
    --region ${REGION} \
    --zone ${ZONE} \
    --subnet ${SUBNET} \
    --no-address \
    --service-account=${GSA} \
    --master-machine-type n1-standard-4 \
    --master-boot-disk-type pd-ssd \
    --master-boot-disk-size 50 \
    --image-version ${IMAGE_VERSION} \
    --bucket ${BUCKET} \
    --initialization-action-timeout=10m \
    --max-idle=${IDLE_TIMEOUT} \
    --enable-component-gateway \
    --scopes='cloud-platform' \
    --enable-kerberos \
    --kerberos-root-principal-password-uri="${INIT_ACTIONS_ROOT}/${KDC_ROOT_PASSWD_KEY}.encrypted" \
    --kerberos-kms-key="${KDC_ROOT_PASSWD_KEY}" \
    --kerberos-kms-key-keyring=${KMS_KEYRING} \
    --kerberos-kms-key-location=global \
    --kerberos-kms-key-project=${PROJECT_ID}

  set +x
  echo "kerberos cluster created"
}

function delete_kerberos_cluster() {
  set -x
  gcloud dataproc clusters delete --quiet --region ${REGION} ${CLUSTER_NAME}
  set +x
  echo "kerberos cluster deleted"
}

function create_phs_cluster() {
# does not include "dataproc:job.history.to-gcs.enabled=true,", as this is a dataproc2 image
  set -x
  gcloud dataproc clusters create ${CLUSTER_NAME}-phs \
    --region=${REGION} \
    --single-node \
    --image-version=${IMAGE_VERSION} \
    --subnet=${SUBNET} \
    --tags=${TAGS} \
    --properties="spark:spark.history.fs.logDirectory=gs://${PHS_BUCKET},spark:spark.eventLog.dir=gs://${PHS_BUCKET}" \
    --properties="mapred:mapreduce.jobhistory.read-only.dir-pattern=gs://${MR_HISTORY_BUCKET}" \
    --enable-component-gateway
  set +x

  echo "==================="
  echo "PHS Cluster created"
  echo "==================="
}

function delete_phs_cluster() {
  set -x
  gcloud dataproc clusters delete --quiet --region ${REGION} ${CLUSTER_NAME}-phs
  set +x
  echo "phs cluster deleted"
}

function create_service_account() {
  set -x
  gcloud iam service-accounts create ${SA_NAME} \
    --description="Service account for use with cluster ${CLUSTER_NAME}" \
    --display-name="${SA_NAME}"

  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${GSA}" \
    --role=roles/dataproc.worker

  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${GSA}" \
    --role=roles/storage.objectCreator

  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${GSA}" \
    --role=roles/storage.objectViewer

  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${GSA}" \
    --role=roles/secretmanager.secretAccessor

  set +x
  echo "service account created"
}

function delete_service_account() {
  set -x

  for svc in spark-executor spark-driver agent ; do
    gcloud iam service-accounts remove-iam-policy-binding \
      --role=roles/iam.workloadIdentityUser \
      --member="serviceAccount:${PROJECT_ID}.svc.id.goog[${DPGKE_NAMESPACE}/${svc}]" \
      "${GSA}"
  done

  gcloud projects remove-iam-policy-binding \
    --role=roles/dataproc.worker \
    --member="serviceAccount:${GSA}" \
    "${PROJECT_ID}"

  gcloud projects remove-iam-policy-binding \
    --role=roles/storage.objectCreator \
    --member="serviceAccount:${GSA}" \
    "${PROJECT_ID}"

  gcloud projects remove-iam-policy-binding \
    --role=roles/storage.objectViewer \
    --member="serviceAccount:${GSA}" \
    "${PROJECT_ID}"
  
  gcloud iam service-accounts delete --quiet ${GSA}

  set +x
  echo "service account deleted"
}

function grant_gke_roles(){
  set -x
  for svc in agent spark-driver spark-executor ; do
    gcloud iam service-accounts add-iam-policy-binding \
      --role=roles/iam.workloadIdentityUser \
      --member="serviceAccount:${PROJECT_ID}.svc.id.goog[${DPGKE_NAMESPACE}/${svc}]" \
      "${GSA}"
  done
  set +x
  echo "dpgke service account roles granted"
}

function create_gke_cluster() {
  set -x
  gcloud container clusters create ${GKE_CLUSTER_NAME} \
    --service-account=${GSA} \
    --workload-pool=${PROJECT_ID}.svc.id.goog \
    --tags ${TAGS} \
    --subnetwork ${SUBNET} \
    --network ${NETWORK}

  set +x
  echo "gke cluster created"
}

function delete_gke_cluster() {
  set -x

  gcloud container clusters delete --quiet ${GKE_CLUSTER_NAME} --zone ${ZONE}

  gcloud container node-pools delete --quiet ${DP_POOLNAME_DEFAULT} \
    --zone ${ZONE} \
    --cluster ${GKE_CLUSTER_NAME}

  set +x
  echo "gke cluster deleted"
}

source lib/database-functions.sh
source lib/net-functions.sh

function create_bucket () {
  if gsutil ls -d gs://${BUCKET} ; then
    echo "bucket already exists, skipping creation."
    return
  fi
  set -x
  gsutil mb -l ${REGION} gs://${BUCKET}
  set +x

  echo "==================="
  echo "Temp bucket created"
  echo "==================="

  # Copy initialization action scripts
  if [ -d init ]
  then
    set -x
    gsutil -m cp -r init/* gs://${BUCKET}/dataproc-initialization-actions
    set +x
  fi

  echo "==================="
  echo "init scripts copied"
  echo "==================="

}

function delete_bucket () {
  set -x
  gsutil -m rm -r gs://${BUCKET}
  set +x

  echo "bucket removed"
}

function create_autoscaling_policy() {
  set -x

  if gcloud dataproc autoscaling-policies describe ${AUTOSCALING_POLICY_NAME} --region ${REGION} > /dev/null 2>&1; then
    echo "policy ${AUTOSCALING_POLICY_NAME} already exists"
  else
    gcloud dataproc autoscaling-policies import ${AUTOSCALING_POLICY_NAME} --region ${REGION} --source autoscaling-policy.yaml
  fi
  set +x

  echo "autoscaling policy created"
}


function delete_autoscaling_policy() {
  set -x

  if gcloud dataproc autoscaling-policies describe ${AUTOSCALING_POLICY_NAME} --region ${REGION} > /dev/null; then  
    gcloud dataproc autoscaling-policies delete --quiet ${AUTOSCALING_POLICY_NAME} --region ${REGION}
  else
    echo "policy ${AUTOSCALING_POLICY_NAME} does not exists"
  fi
  set +x

  echo "autoscaling policy created"
}

function reproduce {
  set -x
  # Run some job on the cluster which triggers the failure state
  # Spark?
  # Map/Reduce?
  # repro: steady load 15K containers
  # zero
  # containers finish
  # customer's use case increased to or above 55K pending containers
  # customer sustained load, increased, completed work, added more work
  # churns but stays high
  # as final work is completed
  # simulate gradual decrease of memory
  # simulate continued increase of containers until yarn pending memory reaches
  # When yarn pending memory should reach zero, it instead decreases below 0

  # https://linux.die.net/man/1/stress

  # consider dd if=/dev/zero | launch_job -
  
  set +x
}

function get_yarn_applications() {
  echo "not yet implemented"
}

function get_jobs_list() {

  if [[ -z ${JOBS_LIST} ]]; then
    JOBS_LIST="$(gcloud dataproc jobs list --region ${REGION} --format json)"
  fi

  echo "${JOBS_LIST}"
}


function diagnose {
  set -x
  local bdoss_path=${HOME}/src/bigdataoss-internal
  if [[ ! -d ${bdoss_path}/drproc ]]; then
    echo "mkdir -p ${bdoss_path} ; pushd ${bdoss_path} ; git clone sso://bigdataoss-internal/drproc ; popd"
    exit -1
  fi
  echo -n "This is going to take some time..."
  # --job-ids <comma separated Dataproc job IDs>
  # --yarn-application-ids <comma separated Yarn application IDs>
  # --stat-time & --end-time
  DIAGNOSE_CMD="gcloud dataproc clusters diagnose ${CLUSTER_NAME} --region ${REGION}"
  DIAG_OUT=$(${DIAGNOSE_CMD} 2>&1)
  echo "Done."

  DIAG_URL=$(echo $DIAG_OUT | perl -ne 'print if m{^gs://.*/diagnostic.tar.gz\s*$}')
  mkdir -p tmp
  gsutil cp -q ${DIAG_URL} tmp/

  if [[ ! -f venv/${CLUSTER_NAME}/pyvenv.cfg ]]; then
    mkdir -p venv/
    python3 -m venv venv/${CLUSTER_NAME}
    source venv/${CLUSTER_NAME}/bin/activate
    python3 -m pip install -r ${bdoss_path}/drproc/requirements.txt
  else
    source venv/${CLUSTER_NAME}/bin/activate
  fi

  python3 ${bdoss_path}/drproc/drproc.py tmp/diagnostic.tar.gz

  set +x
}

function execute_with_retries() {
  local -r cmd=$1
  for ((i = 0; i < 10; i++)); do
    if eval "$cmd"; then
      return 0
    fi
    sleep 5
  done
  return 1
}

function exists_bigtable_instance() {
  BIGTABLE_INSTANCES="$(gcloud bigtable instances list --format=json)"
  JQ_CMD=".[] | select(.name | test(\"${BIGTABLE_INSTANCE}$\"))"
  OUR_INSTANCE=$(echo ${BIGTABLE_INSTANCES} | jq -c "${JQ_CMD}")

  if [[ -z "${OUR_INSTANCE}" ]]; then
    return -1
  else
    return 0
  fi
}

function create_bigtable_instance() {
  set -x
  if exists_bigtable_instance == 0; then
    echo "bigtable instance already exists"
    set +x
    return 0
  fi
  
  gcloud bigtable instances create ${BIGTABLE_INSTANCE} \
    --display-name ${BIGTABLE_DISPLAY_NAME} \
    --cluster-config="${BIGTABLE_CLUSTER_CONFIG}"
  set +x
}

function delete_bigtable_instance() {
  set -x

  gcloud bigtable instances --quiet delete ${BIGTABLE_INSTANCE}

  set +x
}

function get_cluster_uuid() {
  get_cluster_json | jq -r .clusterUuid
}

function get_cluster_json() {
  #  get_clusters_list | jq ".[] | select(.name | test(\"${BIGTABLE_INSTANCE}$\"))"
  if [[ -z "${THIS_CLUSTER_JSON}" ]]; then
    JQ_CMD=".[] | select(.clusterName | contains(\"${CLUSTER_NAME}\"))"
    THIS_CLUSTER_JSON=$(get_clusters_list | jq -c "${JQ_CMD}")
  fi

  echo "${THIS_CLUSTER_JSON}"
}

function get_clusters_list() {
  if [[ -z ${CLUSTERS_LIST} ]]; then
    CLUSTERS_LIST="$(gcloud dataproc clusters list --region ${REGION} --format json)"
  fi
  
  echo "${CLUSTERS_LIST}"
}

# https://cloud.google.com/secret-manager/docs/create-secret-quickstart#secretmanager-quickstart-gcloud
# https://console.cloud.google.com/marketplace/product/google/secretmanager.googleapis.com?q=search&referrer=search&project=${PROJECT_ID}
function enable_secret_manager() {
  gcloud services enable \
    secretmanager.googleapis.com \
    --project=${PROJECT_ID}
}

function create_secret() {
  echo -n "super secret" | gcloud secrets create ${MYSQL_SECRET_NAME} \
    --replication-policy="automatic" \
    --data-file=-

}
