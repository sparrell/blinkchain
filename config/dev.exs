use Mix.Config

log_level = System.get_env("LOG_LEVEL")

config :logger, level: String.to_atom(log_level || "debug")

config :blinkchain,
  canvas: {50, 1}

config :blinkchain, :channel0,
  pin: 18,
  arrangement: [
    %{
      type: :rgb,
      brightness: 32,
      gamma: gamma,
      arrangement: [
        %{
          type: :strip,
          origin: {0, 0},
          count: 50,
          direction: :right
        }
      ]
    }
  ]
