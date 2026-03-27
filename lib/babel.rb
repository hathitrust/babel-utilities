# frozen_string_literal: true

module Babel
end

require_relative "babel/database"
require_relative "babel/services"

# So the Sequel models have a connection on first load
Babel::Services.database
require_relative "babel/model/mb_collection"
require_relative "babel/model/mb_transfer"
require_relative "babel/operation/transfer_collection"
