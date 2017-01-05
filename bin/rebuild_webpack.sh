#!/bin/bash

docker-compose kill webpack && docker-compose rm webpack
docker-compose build
docker-compose create webpack && docker-compose start webpack
docker-compose logs webpack
