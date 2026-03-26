# frozen_string_literal: true

require "sequel"

# +------------------+------------------+------+-----+---------------------+-------------------------------+
# | Field            | Type             | Null | Key | Default             | Extra                         |
# +------------------+------------------+------+-----+---------------------+-------------------------------+
# | MColl_ID         | int(10) unsigned | NO   | PRI | 0                   |                               |
# | collname         | varchar(100)     | NO   | MUL |                     |                               |
# | owner            | varchar(256)     | YES  | MUL | NULL                |                               |
# | owner_name       | varchar(255)     | YES  |     | NULL                |                               |
# | description      | varchar(255)     | YES  |     | NULL                |                               |
# | num_items        | int(11)          | YES  | MUL | NULL                |                               |
# | shared           | tinyint(1)       | YES  | MUL | NULL                |                               |
# | modified         | timestamp        | NO   |     | current_timestamp() | on update current_timestamp() |
# | featured         | date             | YES  | MUL | NULL                |                               |
# | branding         | varchar(2048)    | YES  |     | NULL                |                               |
# | contact_info     | mediumtext       | YES  |     | NULL                |                               |
# | contact_link     | mediumtext       | YES  |     | NULL                |                               |
# | contributor_name | varchar(255)     | YES  |     | NULL                |                               |
# +------------------+------------------+------+-----+---------------------+-------------------------------+

module Babel::Model
  class MBCollection < Sequel::Model(:mb_collection)
    # `owner` and `owner_name` can be NULL, but do we really want to allow that?
    DEFAULT_OWNER = "hathitrust@gmail.com"
    DEFAULT_OWNER_NAME = "HathiTrust"
    MAX_SIGNED_INT_LESS_ONE = 2147483647 - 1

    set_primary_key :MColl_ID

    # Adapted from weird mdp-lib `DBUtils::generate_unique_id` which tries random values in a range.
    # The schema should autoincrement but it doesn't.
    # `initial_candidate` is for testing, it is not expected to be supplied in production code.
    def self.generate_collection_id(initial_candidate: nil)
      unique_id = nil
      loop do
        candidate = initial_candidate || rand(1..MAX_SIGNED_INT_LESS_ONE)
        if where(MColl_ID: candidate).count.zero?
          unique_id = candidate
          break
        end
        initial_candidate = nil
      end
      unique_id
    end

    def self.with_ids(ids)
      where(MColl_ID: ids)
    end

    # Set defaults
    def before_create
      super
      self.MColl_ID = self.class.generate_collection_id
      self.name ||= "Untitled Collection"
      self.owner ||= DEFAULT_OWNER
      self.owner_name ||= DEFAULT_OWNER_NAME
    end

    # Alias
    def id
      self.MColl_ID
    end

    def name
      collname
    end

    def name=(name)
      self.collname = name
    end
  end
end
