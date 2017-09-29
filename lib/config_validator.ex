defmodule ConfigValidator do
  @moduledoc """
  Configuration validation for Mix config files. 

  ## Why

  When you set a Mix configuration value equal to an environment variable,
  that variable must be present at compile time or in your deployment
  environment for your app to function properly.

  It's easy to forget to do this, causing unecessary bugs. ConfigValidator 
  gives you the tools to prevent that from ever happening again.

  ## How
  
  ConfigValidator reads your `config/config.exs` file (or other config file of
  your choosing), and looks for nil settings.

  It is smart enough to understand both of the following ways of referencing
  an ENV variable:

      System.get_env("VAR_NAME")
      {:system, "VAR_NAME"}

  If a nil setting is found, `ConfigValidator` can raise an error at compile
  time, start up, or just log a warning. It's up to you.

  See the following macros and functions for more information:

  - `validate_config_at_compile_time!/1`
  - `validate_config!/1`
  - `validate_config/1`
  """

  defmodule ConfigError do
    @moduledoc """
    This exception is raised in `ConfigValidator` if the any apps have a nil
    configuration setting.
    """

    defexception message: nil, apps: []
    
    def exception(apps) do
      %__MODULE__{
        message: "Some app configuration values are nil! #{inspect(apps)}",
        apps: apps
      }
    end
  end

  @doc """
  Validates a project config file, similar to `validate_config!/1`, but _at
  compile time._

  This is useful to prevent code from being deployed if any of the required
  settings or ENV variables are nil in the deployment environment. The code
  will refuse to compile.

  If your compile environment is different from your runtime environment, or
  if there's a risk that ENV variables might go missing at runtime, you'll also
  want to use `validate_config/1` or `validate_config!/1`.

      defmodule My.Application do
        import ConfigValidator

        def start(_) do
          # Validate that all required ENV vars and settings are present at
          # compile time:
          validate_config_at_compile_time!

          # Validate that all required ENV vars and settings are still present
          # after compile, when the application boots
          validate_config!
        end
      end

  ## Examples
  
  The behaviour is the same as `validate_config!/1`, just at compile time.
  """
  defmacro validate_config_at_compile_time!(config_file \\ nil) do
    validate_config!(config_file)
  end

  @doc """
  Validates a project config file, looking for nil settings. If a nil setting
  is found, will raise `ConfigValidator.ConfigError`.

  ## Examples
  
  You can validate your default config at `config/config.exs`:
  
      iex> validate_config!()
      :ok

  Or a config file at a custom location:

      iex> validate_config!("test/support/valid_config.exs")
      :ok

      iex> validate_config!("test/support/nil_config.exs")
      ** (ConfigValidator.ConfigError) Some app configuration values are nil! [config_validator: [setting: nil]]
  """
  def validate_config!(config_file \\ nil) do
    case validate_config(config_file) do
      {:error, error} -> raise(error)
      other -> other
    end
  end

  @doc """
  Validates a project's config file, looking for nil settings.

  ## Examples
  
  You can validate your default config at `config/config.exs`:

      iex> validate_config()
      :ok

  Or a config file at a custom location:

      iex> validate_config("test/support/valid_config.exs")
      :ok

      iex> validate_config("test/support/nil_config.exs")
      {:error, %ConfigValidator.ConfigError{
        message: "Some app configuration values are nil! [config_validator: [setting: nil]]",
        apps: [config_validator: [setting: nil]]
      }}
  """
  @spec validate_config :: :ok | {:error, ConfigError.t}
  @spec validate_config(String.t) :: :ok | {:error, ConfigError.t}
  def validate_config(config_file \\ nil) do
    config_file = config_file || "config/config.exs"

    problem_apps =
      config_file
      |> Mix.Config.read!
      |> Enum.map(&get_nil_configs/1)
      |> Enum.filter(fn({_app, configs}) -> length(configs) > 0 end)

    if length(problem_apps) > 0 do
      {:error, ConfigError.exception(problem_apps)}
    else
      :ok
    end
  end

  defp get_nil_configs({app, configs}) do
    {app, nil_configs(configs, [])}
  end

  defp nil_configs([], configs), do: configs
  defp nil_configs([{k, v} | t], configs) when is_list(v) do
    nested = nil_configs(v, [])

    if length(nested) > 0 do
      nil_configs(t, [{k, nested} | configs])
    else
      nil_configs(t, configs)
    end
  end
  defp nil_configs([h | t], configs) when is_tuple(h) do
    configs = if config_is_nil?(h), do: [h | configs], else: configs
    nil_configs(t, configs)
  end
  defp nil_configs([h | t], configs) when is_map(h) do
    nested = nil_configs(Enum.to_list(h), [])

    if length(nested) > 0 do
      nil_configs(t, [nested | configs])
    else
      nil_configs(t, configs)
    end
  end

  defp config_is_nil?({_key, {:system, var}}) do
    is_nil(System.get_env(var))
  end

  defp config_is_nil?({_key, value}) do
    is_nil(value)
  end
end
