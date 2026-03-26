# frozen_string_literal: true

require "delegate"
require "sequel"
require_relative "services"

# Shamelessly stolen from holdings_backend
module Babel
  # Backend for connection to MySQL database for production information about
  # holdings and institutions
  class Database < SimpleDelegator
    attr_reader :connection

    def initialize
      @connection = self.class.connection
      # Check once every few seconds that we're actually connected and reconnect if necessary
      @connection.extension(:connection_validator)
      @connection.pool.connection_validation_timeout = 5
      if ENV["LOG_SQL"]
        @connection.loggers << Services.logger
      end
      super(@connection)
    end

    # Connection connects to the database using the connection information
    # specified by environment variables MARIADB_BABEL_USERNAME, _PASSWORD,
    # _HOST, and _DATABASE.
    def self.connection
      Sequel.connect(
        adapter: "trilogy",
        user: ENV["MARIADB_HT_USERNAME"],
        password: ENV["MARIADB_HT_PASSWORD"],
        host: ENV["MARIADB_HT_HOST"],
        database: ENV["MARIADB_HT_DATABASE"],
        encoding: "utf8mb4"
      )
    rescue Sequel::DatabaseConnectionError => e
      Services.logger.error "Error trying to connect"
      raise e
    end
  end
end
