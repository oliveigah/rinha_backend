#!/bin/bash

# git clone --single-branch --quiet https://github.com/zanfranceschi/rinha-de-backend-2023-q3
        
cd rinha-de-backend-2023-q3

# wget https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/3.9.5/gatling-charts-highcharts-bundle-3.9.5-bundle.zip

# unzip gatling-charts-highcharts-bundle-3.9.5-bundle.zip

WORKSPACE=/home/oliveigah/projects/personal/rinha_backend/rinha-de-backend-2023-q3/stress-test

cd gatling-charts-highcharts-bundle-3.9.5

./bin/gatling.sh -rm local -s RinhaBackendSimulation -rd "DESCRICAO" -rf $WORKSPACE/user-files/results -sf $WORKSPACE/user-files/simulations -rsf $WORKSPACE/user-files/resources
