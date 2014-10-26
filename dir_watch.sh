#!/bin/bash

NUM=1

while [ $NUM -gt 0 ]; do
	clear;
	ls -lah $1;
	sleep 2;
done
