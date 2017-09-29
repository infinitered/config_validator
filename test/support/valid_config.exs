use Mix.Config

config :config_validator,
  setting: "value",
  setting_with_map: [%{test: "value"}],
  setting_with_list: [:list]
