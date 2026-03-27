# frozen_string_literal: true

require "canister"
require "dotenv"
require "logger"

require_relative "database"

module Babel
  HOME = File.expand_path(File.join(__dir__, "..", "..")).freeze

  # dotenv is for running outside of Docker/k8s, when there is nothing to set up
  # the environment.
  # From the Dotenv README: "The first value set for a variable will win."
  Dotenv.load(
    File.join(HOME, "config", "env.local"),
    File.join(HOME, "config", "env")
  )

  Services = Canister.new
  Services.register(:database) do
    Database.new.connection
  end

  Services.register(:logger) do
    Logger.new($stdout, level: ENV.fetch("BABEL_LOGGER_LEVEL", Logger::WARN).to_i)
  end
end
