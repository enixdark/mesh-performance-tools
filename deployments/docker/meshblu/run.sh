#!/bin/sh

sed -i s#{{FIREHOSE_REDIS_URI}}#${FIREHOSE_REDIS_URI}#g /usr/src/app/command.coffee
sed -i s#{{CACHE_REDIS_URI}}#${CACHE_REDIS_URI}#g /usr/src/app/command.coffee
sed -i s#{{REDIS_URI}}#${REDIS_URI}#g /usr/src/app/command.coffee
sed -i s/{{CONCURRENCY}}/${CONCURRENCY}/g /usr/src/app/command.coffee
sed -i s#{{MONGODB_URI}}#${MONGODB_URI}#g /usr/src/app/command.coffee
sed -i s/{{PEPPER}}/${PEPPER}/g /usr/src/app/command.coffee
sed -i s#{{ALIAS_SERVER_URI}}#${ALIAS_SERVER_URI}#g /usr/src/app/command.coffee
sed -i s#{{JOB_LOG_REDIS_URI}}#${JOB_LOG_REDIS_URI}#g /usr/src/app/command.coffee
sed -i s/{{MESHBLU_HTTP_PORT}}/${MESHBLU_HTTP_PORT}/g /usr/src/app/command.coffee
sed -i s/{{PRIVATE_KEY_BASE64}}/${PRIVATE_KEY_BASE64}/g /usr/src/app/command.coffee
sed -i s/{{PUBLIC_KEY_BASE64}}/${PUBLIC_KEY_BASE64}/g /usr/src/app/command.coffee

#npm install -g pm2 
#pm2 start process.json

node command.js
