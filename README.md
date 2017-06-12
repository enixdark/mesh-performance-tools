# MeshbluPerformanceTools

**TODO: This is cli tool to test a connect, subsribe, pushlish message to meshblu services, support http, mqtt protocol, websocket, coap'll support in th future**

## Setup

### Requirement

- Elixir v1.4.x
- Nodejs 
- Python 2.7.x

### How to Install app

install all package for elixir app

`mix deps.get`

compile to generate tasks 

`mix compile`

generate binary file through escript

`mix escript.build`

use command to test

`meshblu_performance_tools http`

`meshblu_performance_tools mqtt`

check help through command

`meshblu_performance_tools -h`

if you want to test in with mix you can use command:

`mix cli httt` or `mix http`

`mix cli mqtt` or `mix mqtt`


For http, currently, it's only support subscriber with 2 mode:

- unique: use a uuid and token of a device that have registered
- file: load a uuid and token of a device or devices that u define in file, for sample format file, please check it in samples/data

Example:

to create a request http to meshblu streaming server with 1 concurency request (-c options) / 1 total request (-n options ) and delay every concurency request in 2s (-d options)
for -f options, it'll force a devices or a collections devices load repeat many times if if total uuid/token of devices < totol connection

`mix http -m unique b37b29d6-2f62-48c8-84a5-7ea5477235db:259f6a54f27477ffc63342d2f1614f788bd9724a -c 1 -f -n 1 -d 2000`

or 

`meshblu_performance_tools http -m unique b37b29d6-2f62-48c8-84a5-7ea5477235db:259f6a54f27477ffc63342d2f1614f788bd9724a -c 1 -f -n 1 -d 2000`

or 

`
mix http -m file /home/cqshinn/GIT/meshblu_project/meshblu_performance_tools/samples/files/devices.yaml -c 10
`
