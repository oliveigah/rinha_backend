import Config

config :mnesia, dir: '.mnesia/#{Mix.env()}/#{node()}'

import_config "#{config_env()}.exs"
