#!/bin/bash

# Redis cluster details
REDIS_HOST="newdevcachereplicationgroup.dsnwte.ng.0001.eun1.cache.amazonaws.com"
REDIS_PORT="6379"

# Enter Redis CLI and execute FLUSH ALL
redis-cli -h $REDIS_HOST -p $REDIS_PORT -a $REDIS_PASSWORD FLUSHALL

echo "FLUSH ALL command executed in Redis cluster."
