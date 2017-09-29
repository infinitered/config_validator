# ConfigValidator
[![Build Status](https://semaphoreci.com/api/v1/ir/config_validator/branches/master/shields_badge.svg)](https://semaphoreci.com/ir/config_validator)
[![Hex Version](https://img.shields.io/hexpm/v/config_validator.svg)](https://hex.pm/packages/config_validator)
[![Inline docs](http://inch-ci.org/github/infinitered/config_validator.svg)](http://inch-ci.org/github/infinitered/config_validator)

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

See the [Hex Docs](https://hexdocs.pm/config_validator) for more information.

## Installation

Add `config_validator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:config_validator, "~> 0.1.2"}
  ]
end
```
