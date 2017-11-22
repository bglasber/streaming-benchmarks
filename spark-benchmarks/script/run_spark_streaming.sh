#!/bin/bash

TOPO_NAME="test-topo"
SPARK_MASTER_IP="192.168.152.126"
SPARK_MASTER_HOST="spark://"$SPARK_MASTER_IP":7077"
SPARK_HOME="/hdd1/spark-2.2.0-bin-hadoop2.7"

echo "Creating Redis Data..."
ssh tem26 "cd streaming-benchmarks/data && sudo LEIN_ROOT=true /hdd1/lein run -n --configPath /hdd1/Conf.yaml"

echo "Purging Kafka log..."
ssh tem55 "sudo /hdd1/kafka/kafka_2.11-0.11.0.1/bin/kafka-topics.sh --zookeeper tem60:2181 --create --replication-factor 1 --partitions 5 --topic $TOPO_NAME"

ssh tem55 "sudo /hdd1/kafka/kafka_2.11-0.11.0.1/bin/kafka-topics.sh --zookeeper tem60:2181 --alter --topic $TOPO_NAME --config retention.ms=1000"
sleep 3
ssh tem55 "sudo /hdd1/kafka/kafka_2.11-0.11.0.1/bin/kafka-topics.sh --zookeeper tem60:2181 --alter --topic $TOPO_NAME --config retention.ms=86400000"

echo "Starting Spark Streaming job..."
ssh tem26 "sudo /hdd1/clean_up_spark.sh $SPARK_MASTER_IP"
ssh tem26 "cd streaming-benchmarks && sudo /hdd1/apache-maven-3.2.1/bin/mvn package -DskipTests"
ssh tem26 "cd streaming-benchmarks && sudo /hdd1/submit_spark_job.sh SPARK_HOME SPARK_MASTER_HOST"

echo "Waiting for it to start up..."
sleep 30

echo "Launching all benchmark machines..."
ssh tem103 "cd streaming-benchmarks/data && sudo LEIN_ROOT=true /hdd1/lein run -r -t 17000 --configPath /hdd1/Conf.yaml" &> /dev/null &
ssh tem104 "cd streaming-benchmarks/data && sudo LEIN_ROOT=true /hdd1/lein run -r -t 17000 --configPath /hdd1/Conf.yaml" &> /dev/null &
ssh tem105 "cd streaming-benchmarks/data && sudo LEIN_ROOT=true /hdd1/lein run -r -t 17000 --configPath /hdd1/Conf.yaml" &> /dev/null &
ssh tem106 "cd streaming-benchmarks/data && sudo LEIN_ROOT=true /hdd1/lein run -r -t 17000 --configPath /hdd1/Conf.yaml" &> /dev/null &
ssh tem107 "cd streaming-benchmarks/data && sudo LEIN_ROOT=true /hdd1/lein run -r -t 17000 --configPath /hdd1/Conf.yaml" &> /dev/null &
ssh tem108 "cd streaming-benchmarks/data && sudo LEIN_ROOT=true /hdd1/lein run -r -t 17000 --configPath /hdd1/Conf.yaml" &> /dev/null &
ssh tem109 "cd streaming-benchmarks/data && sudo LEIN_ROOT=true /hdd1/lein run -r -t 17000 --configPath /hdd1/Conf.yaml" &> /dev/null &

echo "Running for 30 minutes..."
sleep 1800

echo "Killing all processes..."
ps aux | grep lein | awk '{print $2;}' | xargs sudo kill

ssh tem103 "cd streaming-benchmarks/data && sudo LEIN_ROOT=true /hdd1/lein run -g --configPath /hdd1/Conf.yaml"



