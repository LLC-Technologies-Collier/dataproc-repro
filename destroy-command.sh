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

#set -e

source env.sh

delete_standard_cluster

delete_service_account

delete_autoscaling_policy

#delete_phs_cluster()

#delete_mysql_instance
#delete_legacy_mssql_instance

delete_router

delete_firewall_rules

#delete_logging_firewall_rules

#delete_ip_allocation

delete_subnet

delete_vpc_network

#delete_vpc_peering

delete_bucket

set +x
