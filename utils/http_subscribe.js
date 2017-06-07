import * as util from 'util'
import * as path from 'path'
import * as url from 'url'
import * as colors from 'colors'
import Promise from 'bluebird'
import request from 'request'


const argv = require('optimist')
        .usage("Cli tool to test performance for meshblu")
        .options('u', { alias: 'uri', describe: 'request to uri of meshblu service . Default: localhost' })
        .options('p', { alias: 'port', describe: 'request to port of mesh. example: 3001'})
        .options('s', { alias: 'protocol', describe: 'request to protocol of mesh. example: https or http, tcp , Default: http' })
        .options('b', { alias: 'hostname', describe: 'request to domain of mesh. Default: localhost' })
        .options('U', { alias: 'username', describe: 'username of meshblu service'})
        .options('P', { alias: 'password', describe: 'password of meshblu service'})
        .boolean('v', { alias: "verbose", describe: 'Verbose output' })
        .boolean('h', { alias: 'help', describe: 'Print this usage and exit' })
        .argv

const URL = require('url')
const MeshbluHttp = require('meshblu-http')
let meshbluHttp

function usage(exit) {
    console.log(require('optimist').help())
}

function subscribe({protocol, host, port, username, password}){
    console.log(`${protocol}//${host}:${port}/subscribe`, username, password)
    request.get({
      url: `${protocol}//${host}:${port}/subscribe`,
      headers: {
        'meshblu_auth_token': password,
        'meshblu_auth_uuid': username
      }
    })
    .on('response', function(response) {
      console.log(response.statusCode) 
      console.log(response.headers['content-type']) 
    })
    .on('data', function(response) {
        console.log('info',response.toString()) 
    })
    .on('error', function(err){
        console.log('error', error)
    })
}

function main(){

  if(argv.h){
    usage()
    process.exit(0)
  }
  let username, password
  let uri = URL.parse(argv.u || "http://b37b29d6-2f62-48c8-84a5-7ea5477235db:259f6a54f27477ffc63342d2f1614f788bd9724a@ads-elb-external-1267527463.ap-southeast-1.elb.amazonaws.com:3001")
  let port = argv.p || uri.port
  let host = argv.hostname || uri.hostname
  let protocol = argv.s || uri.protocol
  let topic = argv.T || 'message'
  if(uri.auth){
    password = argv.P || uri.auth.split(":")[1]
    username = argv.U || uri.auth.split(":")[0]
  }

  publish({
    protocol,
    host,
    port,
    username,
    password
  })
}

main()






