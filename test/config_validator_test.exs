defmodule ConfigValidatorTest do
  use ExUnit.Case

  import ConfigValidator

  doctest ConfigValidator, import: true

  describe ".validate_config/1" do
    test "returns :ok when all env vars are set" do
      with_env %{"TEST_VAR" => "value"}, fn ->
        assert :ok = validate_config("test/support/env_config.exs")
      end
    end

    test "returns :error when one env var is missing" do
      assert {:error, %{apps: apps}} = validate_config("test/support/env_config.exs")
      app = apps[:config_validator]
      assert Keyword.has_key?(app, :direct_env)
      assert Keyword.has_key?(app, :tuple_env)
      assert Keyword.has_key?(app[:nested], :direct_env)
      assert Keyword.has_key?(app[:nested], :tuple_env)
      assert Keyword.has_key?(app[ConfigValidator], :direct_env)
      assert Keyword.has_key?(app[ConfigValidator], :tuple_env)
      assert [[key: nil]] = apps[:config_validator][:nested_with_maps]
    end
  end

  defp with_env(vars, fun) do
    System.put_env(vars)
    fun.()
    vars
    |> Map.keys
    |> Enum.each(&System.delete_env/1)
  end
end
