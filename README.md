# MeshbluPerformanceTools

**TODO: This is cli tool to test a connect, subsribe, pushlish message to meshblu services, support http, mqtt protocol, websocket, coap'll support in th future**

## Setup

###Requirement

- Elixir v1.4.x
- Nodejs 
- Python 2.7.x
- Mongodb
- Redis-server

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

