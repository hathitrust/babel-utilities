# frozen_string_literal: true

require "json"
require "securerandom"
require "sequel"

# +---------------------+------------------+------+-----+---------------------+----------------+
# | Field               | Type             | Null | Key | Default             | Extra          |
# +---------------------+------------------+------+-----+---------------------+----------------+
# | id                  | int(11) unsigned | NO   | PRI | NULL                | auto_increment |
# | token               | varchar(36)      | NO   | MUL |                     |                |
# | submitter           | varchar(255)     | NO   | MUL |                     |                |
# | submitter_usernames | text             | NO   |     | '[]'                |                |
# | receiver            | varchar(255)     | YES  |     | NULL                |                |
# | payload             | text             | YES  |     | NULL                |                |
# | created             | timestamp        | NO   |     | current_timestamp() |                |
# | completed           | timestamp        | YES  |     | NULL                |                |
# +---------------------+------------------+------+-----+---------------------+----------------+

module Babel::Model
  class MBTransfer < Sequel::Model(:mb_transfer)
    def self.with_submitter(submitter)
      where(submitter: submitter)
    end

    # Set defaults
    def before_create
      super
      self.token = SecureRandom.uuid
    end

    # Sample of real data from mb_transfer:
    # ["1523981214","801530158"]
    # Returns an Array of Integer
    def payload
      return [] if self[:payload].nil?

      JSON.parse(self[:payload]).map(&:to_i)
    end

    # Does not validate that the payload members are existing mb_collection.MColl_ID,
    # but could do so.
    def payload=(payload)
      if !payload.is_a?(Array)
        raise "payload= argument must be an Array"
      end

      self[:payload] = payload.map(&:to_s).to_json
    end

    # schema defaults to '[]' so there's no chance of a `nil` here.
    def submitter_usernames
      JSON.parse(self[:submitter_usernames])
    end

    def submitter_usernames=(names)
      if !names.is_a?(Array)
        raise "names= argument must be an Array"
      end

      self[:submitter_usernames] = names.map(&:to_s).to_json
    end
  end
end
