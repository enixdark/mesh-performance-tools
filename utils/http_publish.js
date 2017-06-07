import * as util from 'util'
import * as path from 'path'
import * as url from 'url'
import * as colors from 'colors'
import Promise from 'bluebird'
import request from 'request'


const argv = require('optimist')
        .usage("Cli tool to test performance for meshblu")
        .options('m', { alias:'messasge', describe: 'message to sent to meshblu service' })
        .options('u', { alias: 'uri', describe: 'request to uri of meshblu service . Default: localhost' })
        .options('p', { alias: 'port', describe: 'request to port of mesh. example: 3000'})
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

function publish({protocol, host, port, username, password, message}){
    request.post({
      url: `${protocol}//${host}:${port}/messages`,
      headers: {
        'meshblu_auth_token': password,
        'meshblu_auth_uuid': username,
        'Content-Type': 'application/json',
      },
      json: message
    }, (err, res, body) => {
      if(res.statusCode == 204)
        console.log("sending a message to server")
    })
    // .on('response', function(response) {
    //   console.log(response.statusCode) 
    //   console.log(response.headers['content-type']) 
    // })
    
}

function main(){

  if(argv.h){
    usage()
    process.exit(0)
  }
  let message = JSON.parse(argv.m || '{"devices":["07d0fda7-2972-4aa7-b9d1-1c7e95adfe2f"],"topic":["default"], "fromUuid":"d1e9750a-590e-48e2-b803-f62c62bb2073"}')
  let username, password
  let uri = URL.parse(argv.u || "http://b37b29d6-2f62-48c8-84a5-7ea5477235db:259f6a54f27477ffc63342d2f1614f788bd9724a@ads-elb-external-1267527463.ap-southeast-1.elb.amazonaws.com:3000")
  let port = argv.p || uri.port
  let host = argv.h || uri.hostname
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
    password,
    message
  })
}

main()






