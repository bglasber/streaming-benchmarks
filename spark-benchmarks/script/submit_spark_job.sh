#!/bin/bash
# 1st argument SPARK_HOME
# 2nd argument SPARK_MASTER_HOST
# e.g. 
# SPARK_MASTER_HOST="spark://192.168.152.126:7077"
# SPARK_HOME="/hdd1/spark-2.2.0-bin-hadoop2.7"
# must be in stremaing benchmark directory to find jar

sudo nohup $1/bin/spark-submit --master $2 --deploy-mode cluster --class spark.benchmark.KafkaRedisAdvertisingStream ./spark-benchmarks/target/spark-benchmarks-0.1.0.jar /hdd1/Conf.yaml > $1/logs/temp 2>&1 &