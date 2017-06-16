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


Currently, it's only support subscriber with 2 mode:

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

for options , you'll have to provide at least a mode format to run tool, default options will load from config file in config/configs.ex. if you don't want to use default config, can use parameters via command:

`mix cli -h`

`mix http -h`

`mix mqtt -h`

or 

`meshblu_performance_tools -h`


### Log & Report

#### Report

Currently , this version's not support report

Ongoing . . .

#### Log

default, Using console to output information, however if you don't want, you can output to logfile by uncomment line and config it in config/config.ex

Example: 
```
config :logger,
  backends: [{LoggerFileBackend, :info},
             {LoggerFileBackend, :error}]

config :logger, :info,
  path: "logs/info.log",
  level: :info

config :logger, :error,
  path: "logs/error.log",
  level: :error
```

### Register, Subscribe, Publish and Create devices file 

Please check it in `utils` folder, this folder include some cli tool to use for meshblu server.

Before use, please install Node.js or Python:


For Python:

please use pyenv, or virtualenv ans install package through pip:

pip install -r requirements.txt

then, to check all options use:

`python register.py -h`

to register one or many devices, use register cli:

```python register.py -n [number]```

or for custom server and body params, use: 

```python register.py --body "subscriberAccount=QN0000000;serialNumber=QN00000001;check=vTanJPNjzXCunbklJVVOPg==" -H http://localhost:3000 -n 10```

or to load devices from a file use:

```python register.py --body path/log.json -H http://localhost:3000 -n 10```

note: this version of cli only support json

---

For Node.js:

install babel node to use for cli tool 

`npm i -g babel-cli`

install all package to use for cli tools

`npm i package.json`


then, to check all options use:

`babel-node register -h`

to register one or many devices, use register cli:

```babel-node register.js -n [number]```

or for custom server and body params, use: 

```babel-node register.js --body "subscriberAccount=QN0000000;serialNumber=QN00000001;check=vTanJPNjzXCunbklJVVOPg==" -u http://localhost:3000 -n 10```

or to load devices from a file use:

```babel-node register.js --body path/log.json -u http://localhost:3000 -n 10```

### Parsing  sample data file

To generate a sample data file from logfile use
 
`python parse.py` 
