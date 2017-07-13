# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :meshblu_performance_tools, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:meshblu_performance_tools, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#
# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
    # import_config "#{Mix.env}.exs"
# ================== console ==================

# config :logger, level: :info

# ================== log file ==================
config :logger,
  backends: [{LoggerFileBackend, :info}]

# uncomment if only to use unique log file   

# config :logger, :info,
#   path: "logs/info.log",
#   level: :info
# config :logger,
#   backends: [{LoggerFileBackend, :info},
#              {LoggerFileBackend, :error}]

# uncomment if want to split between info and error file

config :logger, :info,
  path: "logs/info.log",
  level: :info

config :logger, :error,
  path: "logs/error.log",
  level: :error1

# ================== logstash ==================

# config :logger,
#   backends: [{LoggerLogstashBackend, :info},
#                {LoggerFileBackend, :error}]

# config :logger, :info,
#   host: "0.0.0.0",
#   port: 5000,
#   level: :debug,
#   type: "log",
#   metadata: [
#     extra_fields: "meshblu"
#   ]

config :meshblu_performance_tools, :uri, System.get_env("URI") || "http://ads-elb-external-1267527463.ap-southeast-1.elb.amazonaws.com:3001" #"http://localhost:3000"
# config :meshblu_performance_tools, :stream_uri, System.get_env("STREAM_URI") || "http://ads-elb-external-1267527463.ap-southeast-1.elb.amazonaws.com:3001" #"http://localhost:3001"
config :meshblu_performance_tools, :mqtt_uri, System.get_env("MQTT_URI") || "http://localhost:1883" #"http://localhost:1883"

config :meshblu_performance_tools, :concurrency, System.get_env("CONCURRENCY") || 1
config :meshblu_performance_tools, :max_connection, System.get_env("MAX_CONNECTION") || 1
config :meshblu_performance_tools, :delay, System.get_env("DELAY") || 1_000
config :meshblu_performance_tools, :timeout, System.get_env("TIMEOUT") || 5_000_000
config :meshblu_performance_tools, :ibrowse_max_connection, System.get_env("IBROWSE_MAX_CONNECTION") || 1_000_000
config :meshblu_performance_tools, :loop_time, System.get_env("LOOP_TIME") || 1_000

# config :ecto_mnesia,
#   host: {:system, :atom, "MNESIA_HOST", Kernel.node()},
#   storage_type: {:system, :atom, "MNESIA_STORAGE_TYPE", :ram_copies}

# config :mnesia,
#   dir: 'priv/data/mnesia' # Make sure this directory exists

# config :meshblu_performance_tools, :ecto_repos, [MeshbluPerformanceTools.Repo]
# config :meshblu_performance_tools, MeshbluPerformanceTools.Repo, adapter: EctoMnesia.Adapter

