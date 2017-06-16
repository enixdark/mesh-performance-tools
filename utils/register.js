#!/usr/bin/env babel-node

import * as util from 'util'
import * as path from 'path'
import * as url from 'url'
import * as colors from 'colors'
import Promise from 'bluebird'
import request from 'request-promise'
import winston from 'winston'
import sleep from 'sleep'

const argv = require('optimist')
        .usage("Cli tool to test performance for meshblu")
        .options('c', { alias:'concurrency', describe: 'Number of concurrent requests. Default: 2' })
        .options('n', { alias:'total', describe: 'Max number of total requests. Default: 50' })
        .options('d', { alias: 'delay', describe: 'Delay time for every request. Default: 3' })
        .options('u', { alias: 'uri', describe: 'request to uri of meshblu service . Default: localhost:3000' })
        .options('p', { alias: 'protocol', describe: 'request to protocol of mesh. Default: http' })
        .options('B', { alias: 'body', describe: 'body content. Default: {}' })
        .options('l', { alias: 'logpath', describe: 'path to save log' })
        .boolean('v', { alias: "verbose", describe: 'Verbose output' })
        .boolean('h', { alias: 'help', describe: 'Print this usage and exit' })
        .argv

const URL = require('url')
const MeshbluHttp = require('meshblu-http')
const fs = Promise.promisifyAll(require('fs'))
const bunyan = require('bunyan')
const RotatingFileStream = require('bunyan-rotating-file-stream')
let logger = console
let log_path = argv.l || `../logs/devices.log`
let stream = fs.createWriteStream(log_path, { flags : 'w' })

let meshbluHttp

function usage(exit) {
    let help = require('optimist').help().split('\n')
    help.pop()
    // add a message for boolean options
    // help.push('  -f, --force        switch mode request to for custom meshblu server       ')
    help.push('')
    console.log(help.join('\n'))
}




function register({protocol, host, port}){
    return meshbluHttp.registerAsync({})
            .then( res => {
              logger.info(Object.assign(res, {protocol, host, port }))
            })
            .catch(function(error){
              logger.info(error)
            })
}

function register_custom_server({protocol, host, port, body}){
    return request.post({
              url: `${protocol}//${host}:${port}/ADServer/devices/register`,
              headers: {
                'Content-Type': 'application/json',
                'User-Agent': 'Request-Promise'
              },
              body: body,
              json: true 
            })
            .then( res => {
              logger.info(Object.assign(res, {protocol, host, port }))
            })
            .catch(function(error){
              logger.info(error)
            })
}




function main(){

  let log_path = argv.l || `../logs/devices.log`
  let stream = fs.createWriteStream(log_path, { flags : 'w' });

  // if(!argv.v){
    
  //   let log_path = argv.l || `../logs/devices.log`
  //   logger = bunyan.createLogger({
  //     name: 'regiter',
  //     streams: [{
  //           type: 'raw',
  //           stream: new RotatingFileStream({
  //               path: log_path,
  //               period: '1d',          // daily rotation 
  //               totalFiles: 10,        // keep 10 back copies 
  //               rotateExisting: true,  // Give ourselves a clean file when we start up, based on period 
  //               threshold: '10m',      // Rotate log files larger than 10 megabytes 
  //               totalSize: '20m',      // Don't keep more than 20mb of archived log files 
  //               gzip: true             // Compress the archive log files to save space 
  //           })
  //     }]
  //     // streams: [
  //     //   {
  //     //     level: 'info',
  //     //     // stream: procedss.stdout
  //     //     stream: process.stdout
  //     //   },
  //     //   {
  //     //     level: 'error',
  //     //     // stream: process.stdout
  //     //     path: log_path
  //     //   }
  //     // ]
  //   })
  // }

  
  if(argv.h){
    usage()
    process.exit(0)
  }
  let uri = URL.parse(argv.u || "http://localhost:3000")
  let port = argv.p || uri.port || 3000
  let host = uri.hostname || 'localhost'
  let protocol = argv.s || uri.protocol || 'http'
  let number = argv.n || 1
  let concurrency = argv.c || 1
  meshbluHttp = Promise.promisifyAll(new MeshbluHttp({
      protocol: protocol, 
      hostname: host,
      port: port
  }))  
  // let avg = number / concurrency
  // for(var i = 0; i < avg; i++){
  //   for(var j = 0; j < concurrency; j++){
  //     register({protocol, host, port})
  //   }
  //   sleep.sleep(3)
  // }

  if(argv.body){
    fs.statAsync(argv.body)
    .then( res => fs.readFileAsync(argv.body))
    .then( res => {
      
      let list = JSON.parse(res)['devices']
      let number = list.length
      for(var i = 0; i < number; i++){ 
        stream.write(str(i))
        let body = list[i]
        // sleep.sleep(1)
        // register_custom_server({protocol, host, port, body})
      }
      // stream.end()
    })
    .catch( err => {
      let body = err.path.split(';').map( item => item.split(/=(.+)/).slice(0,2) )
                         .reduce( (init, next) => { init[next[0]] = next[1] ; return init} , {})
      for(var i = 0; i < number; i++){ 
        register_custom_server({protocol, host, port, body})
      }
    })
  }
  else{
    for(var i = 0; i < number; i++){
      register({protocol, host, port})
    }
  }
}

main()
