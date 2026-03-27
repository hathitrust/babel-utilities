# frozen_string_literal: true

require "climate_control"
require "sequel"

module Babel
  RSpec.describe(Database) do
    describe "#new" do
      it "returns a Database" do
        expect(described_class.new).to be_a(described_class)
      end

      context "with LOG_SQL" do
        it "uses our logger" do
          ClimateControl.modify LOG_SQL: "1" do
            expect(described_class.new.loggers.index(Services.logger)).not_to eq(nil)
          end
        end
      end

      context "without LOG_SQL" do
        it "does not use our logger" do
          ClimateControl.modify LOG_SQL: nil do
            expect(described_class.new.loggers.index(Services.logger)).to eq(nil)
          end
        end
      end

      it "raises if credentials are not valid" do
        ClimateControl.modify MARIADB_HT_PASSWORD: nil do
          silence_log do
            expect {
              described_class.new
            }.to raise_error(Sequel::DatabaseConnectionError)
          end
        end
      end
    end
  end
end
