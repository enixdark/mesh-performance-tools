import * as util from 'util'
import * as path from 'path'
import * as url from 'url'
import * as colors from 'colors'
import Promise from 'bluebird'
import request from 'request'
import winston from 'winston'
import sleep from 'sleep'


const argv = require('optimist')
        .usage("Cli tool to test performance for meshblu")
        .options('c', { alias:'concurrency', describe: 'Number of concurrent requests. Default: 2' })
        .options('n', { alias:'total', describe: 'Max number of total requests. Default: 50' })
        .options('d', { alias: 'delay', describe: 'Delay time for every request. Default: 3' })
        .options('u', { alias: 'uri', describe: 'request to uri of meshblu service . Default: localhost:3000' })
        .options('p', { alias: 'protocol', describe: 'request to protocol of mesh. Default: http' })
        .options('b', { alias: 'hostname', describe: 'request to domain of mesh. Default: localhost' })
        .options('l', { alias: 'logpath', describe: 'path to save log' })
        .boolean('v', { alias: "verbose", describe: 'Verbose output' })
        .boolean('h', { alias: 'help', describe: 'Print this usage and exit' })

        .argv

const URL = require('url');
const MeshbluHttp = require('meshblu-http')
const locks = require('locks')
const mutex = locks.createMutex()
// assign a variable to use as parent log
let logger = console

let meshbluHttp

function usage(exit) {
    console.log(require('optimist').help())
}


function register({protocol, host, port}){
    return meshbluHttp.registerAsync({})
            .then( res => {
              logger.log('info', Object.assign(res, {protocol, host, port }))
            })
            .catch(function(error){
              logger.log('error', error)
            })
}




function main(){

  if(!argv.v){
    logger = winston
    let log_path = argv.l || `../logs/devices.log`
    winston.configure({
        level: 'debug',
        transports: [
            new (winston.transports.File)({ filename: log_path })
        ]
    })
  }
  
  if(argv.h){
    usage()
    process.exit(0)
  }
  let uri = URL.parse(argv.u || "http://localhost:3000")
  let port = argv.p || uri.port
  let host = argv.hostname || uri.hostname
  let protocol = argv.s || uri.protocol
  let number = argv.n || 1
  meshbluHttp = Promise.promisifyAll(new MeshbluHttp({
      protocol: protocol, 
      hostname: host,
      port: port
  }))  
  for(var i = 0; i < number; i++)
    register({protocol, host, port})
    



}

main()






