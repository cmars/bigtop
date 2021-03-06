#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This file contains environment variables required to run Alluxio. Copy it as alluxio-env.sh and
# edit that to configure Alluxio for your site. At a minimum,
# the following variables should be set:
#
# - JAVA_HOME, to point to your JAVA installation
# - ALLUXIO_MASTER_ADDRESS, to bind the master to a different IP address or hostname
# - ALLUXIO_UNDERFS_ADDRESS, to set the under filesystem address.
# - ALLUXIO_WORKER_MEMORY_SIZE, to set how much memory to use (e.g. 1000mb, 2gb) per worker
# - ALLUXIO_RAM_FOLDER, to set where worker stores in memory data
# - ALLUXIO_UNDERFS_HDFS_IMPL, to set which HDFS implementation to use (e.g. com.mapr.fs.MapRFileSystem,
#   org.apache.hadoop.hdfs.DistributedFileSystem)

# The following gives an example:

if [[ `uname -a` == Darwin* ]]; then
  # Assuming Mac OS X
  export JAVA_HOME=${JAVA_HOME:-$(/usr/libexec/java_home)}
  export ALLUXIO_RAM_FOLDER=/Volumes/ramdisk
  export ALLUXIO_JAVA_OPTS="-Djava.security.krb5.realm= -Djava.security.krb5.kdc="
else
  # Assuming Linux
  if [ -z "$JAVA_HOME" ]; then
    export JAVA_HOME=/usr/lib/jvm/java-7-oracle
  fi
  export ALLUXIO_RAM_FOLDER=/mnt/ramdisk
fi

export JAVA="$JAVA_HOME/bin/java"

echo "Starting alluxio w/ java = $JAVA "

export ALLUXIO_MASTER_ADDRESS=<%= @master_host %>
export ALLUXIO_UNDERFS_ADDRESS=$ALLUXIO_HOME/underfs
#export ALLUXIO_UNDERFS_ADDRESS=hdfs://localhost:9000
export ALLUXIO_WORKER_MEMORY_SIZE=1GB
export ALLUXIO_UNDERFS_HDFS_IMPL=org.apache.hadoop.hdfs.DistributedFileSystem

echo "ALLUXIO master => $ALLUXIO_MASTER_ADDRESS "

CONF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export ALLUXIO_JAVA_OPTS+="
  -Dlog4j.configuration=file:$CONF_DIR/log4j.properties
  -Dalluxio.debug=false
  -Dalluxio.underfs.address=$ALLUXIO_UNDERFS_ADDRESS
  -Dalluxio.underfs.hdfs.impl=$ALLUXIO_UNDERFS_HDFS_IMPL
  -Dalluxio.data.folder=$ALLUXIO_UNDERFS_ADDRESS/tmp/alluxio/data
  -Dalluxio.workers.folder=$ALLUXIO_UNDERFS_ADDRESS/tmp/alluxio/workers
  -Dalluxio.worker.memory.size=$ALLUXIO_WORKER_MEMORY_SIZE
  -Dalluxio.worker.data.folder=$ALLUXIO_RAM_FOLDER/alluxioworker/
  -Dalluxio.master.worker.timeout.ms=60000
  -Dalluxio.master.hostname=$ALLUXIO_MASTER_ADDRESS
  -Dalluxio.master.journal.folder=$ALLUXIO_HOME/journal/
  -Dorg.apache.jasper.compiler.disablejsr199=true
  -Djava.net.preferIPv4Stack=true
"

# Master specific parameters. Default to ALLUXIO_JAVA_OPTS.
export ALLUXIO_MASTER_JAVA_OPTS="$ALLUXIO_JAVA_OPTS"

# Worker specific parameters that will be shared to all workers. Default to ALLUXIO_JAVA_OPTS.
export ALLUXIO_WORKER_JAVA_OPTS="$ALLUXIO_JAVA_OPTS"
