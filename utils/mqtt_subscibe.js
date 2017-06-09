#!/usr/bin/env babel-node

import Promise from 'bluebird'
import request from 'request'
import winston from 'winston'
import sleep from 'sleep'

import Meshblu from 'meshblu-mqtt'
const URL = require('url')
const argv = require('optimist')
        .usage("Cli tool to test performance for meshblu")
        // .options('r', { alias:'register', describe: 'register account from meshblu service' })
        .options('T', { alias: 'topic', describe: 'topic to subscribe' })
        .options('t', { alias: 'timeout', describe: 'timeout for every request. Default: 3' })
        .options('u', { alias: 'uri', describe: 'request to uri of meshblu service . Default: localhost' })
        .options('p', { alias: 'port', describe: 'port of meshblu service . Default: 1883' })
        .options('b', { alias: 'hostname', describe: 'request to domain of mesh. Default: localhost' })
        .options('U', { alias: 'username', describe: 'username of meshblu service'})
        .options('P', { alias: 'password', describe: 'password of meshblu service'})
        .options('s', { alias: 'protocol', describe: 'request to protocol of mesh select between https, http and mqtt. Default: http' })
        .options('n', { alias: 'number', describe: 'number of request to send message' })
        .options('c', { alias: 'qos', describe: 'qos if use ' })
        .boolean('v', { alias: "verbose", describe: 'Verbose output' })
        .boolean('h', { alias: 'help', describe: 'Print this usage and exit' })
      .argv

// babel-node mqtt_publish.js -m '{"devices": ["*"], "topic": "message", "payload": "test"}'

/**
 * show menu optional of publish
 */

function usage() {
    console.log(require('optimist').help())
}


/**
 *  send a message with json data
 *  
 *  @param client: a obj containt information to connect to mmqtt
 *  @param message: content of message to sent to mqtt
 *  example: 
 *  {
 *      devices: ['*'],
 *      topic: 'message',
 *      payload: "hello world"
 *  }
 */ 

function subscribe(client, topic){
  client.connect( (res) => {
     client.subscribe(topic)
  })
}

function main(){
  if(argv.h){
    usage()
    process.exit(0)
  }
  else{
    let username, password
    let uri = URL.parse(argv.u || 'http://47706d7d-a6db-4edd-b7a1-f7aebc5bef4e:e6869b631aa3d521a842752f8ed7300d62fa9332@localhost:1883')
    let port = argv.p || uri.port
    let host = argv.hostname || uri.hostname
    let protocol = argv.s || uri.protocol
    let topic = argv.T || 'message'
    if(uri.auth){
      password = argv.P || uri.auth.split(":")[1]
      username = argv.U || uri.auth.split(":")[0]
    }
    let qos = argv.c || 0
    let retrain = argv.r || false

    let client = new Meshblu({
      "token": password,
      "uuid": username,
      "protocol": protocol,
      "hostname": host,
      "port": port,
      "qos": qos
    })
    client.on('message', (message) => {
      console.log(message)
    })
    subscribe(client, topic)
  }
}

main()