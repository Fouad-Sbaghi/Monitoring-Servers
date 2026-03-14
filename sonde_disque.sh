#!/bin/bash

Occupation=$(df -h / | grep / | awk '{print $5}')
echo "TIMESTAMP:$(date +%s)|DISK:$Occupation"