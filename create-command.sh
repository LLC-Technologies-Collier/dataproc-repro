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

# Exit on failure
set -e

source env.sh

create_project

configure_gcloud

set_cluster_name

enable_services

create_bucket

create_vpc_network

#create_ip_allocation

#create_vpc_peering

# Create a cloud router

create_router

add_nat_policy

# create subnet

create_subnet

create_firewall_rules

create_service_account

# Create logging firewall rules

#create_logging_firewall_rules

#create_bigtable_instance

#create_mysql_instance
#create_legacy_mssql_instance

# Create PHS dataproc cluster

#create_phs_cluster

# Create normal dataproc cluster

create_autoscaling_policy

create_standard_cluster

# Perform some connectivity tests

#perform_connectivity_tests

