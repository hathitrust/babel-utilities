# frozen_string_literal: true

require "sequel"

module Babel::Model
  RSpec.describe(MBCollection) do
    around(:each) do |example|
      described_class.dataset.delete
      example.run
      described_class.dataset.delete
    end

    describe "#generate_collection_id" do
      it "returns an Integer" do
        expect(described_class.generate_collection_id).to be_a(Integer)
      end

      it "returns an id that does not collide with existing collection" do
        collection = described_class.create
        expect(
          described_class.generate_collection_id(initial_candidate: collection.id)
        ).not_to eq(collection.id)
      end
    end

    describe "#with_ids" do
      it "returns multiple collections for multiple ids" do
        collections = [
          described_class.create,
          described_class.create
        ]
        expect(described_class.with_ids(collections.map(&:id)).count).to eq(2)
      end

      it "returns one collections for a single id" do
        collections = [
          described_class.create
        ]
        expect(described_class.with_ids(collections.first.id).count).to eq(1)
      end
    end

    describe ".create" do
      it "returns a Collection with default values" do
        collection = described_class.create
        expect(collection).to be_a(described_class)
        expect(collection.id).not_to eq(nil)
        expect(collection.name).not_to eq(nil)
        expect(collection.owner).not_to eq(nil)
        expect(collection.owner_name).not_to eq(nil)
      end

      it "uses aliased column names" do
        collection = described_class.create(name: "My Whizzy Collection")
        expect(collection.id).not_to eq(nil)
        expect(collection.name).to eq("My Whizzy Collection")
      end
    end
  end
end
