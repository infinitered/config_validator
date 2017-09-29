use Mix.Config

config :config_validator,
  direct_env: System.get_env("TEST_VAR"),
  tuple_env: {:system, "TEST_VAR"},
  nested: [
    direct_env: System.get_env("TEST_VAR"),
    tuple_env: {:system, "TEST_VAR"}
  ],
  nested_with_maps: [
    %{key: System.get_env("TEST_VAR")}
  ]

config :config_validator, ConfigValidator,
  direct_env: System.get_env("TEST_VAR"),
  tuple_env: {:system, "TEST_VAR"}

