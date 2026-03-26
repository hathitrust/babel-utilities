# frozen_string_literal: true

require "sequel"

module Babel::Model
  RSpec.describe(MBTransfer) do
    around(:each) do |example|
      described_class.dataset.delete
      example.run
      described_class.dataset.delete
    end

    describe ".create" do
      it "returns a MBTransfer with the expected default values" do
        transfer = described_class.create
        expect(transfer).to be_a(described_class)
        expect(transfer.id).not_to eq(nil)
        expect(transfer.token).to be_a(String)
        expect(transfer.submitter_usernames).to eq([])
        expect(transfer.payload).to eq([])
      end

      it "uses aliased column names" do
        transfer = described_class.create(submitter: "test@default.invalid", payload: ["123"])
        expect(transfer.submitter).to eq("test@default.invalid")
        expect(transfer.payload).to eq([123])
      end
    end

    describe ".with_submitter" do
      it "returns the expected transfer" do
        collection = MBCollection.create(owner: "test@default.invalid", name: "Collection to Transfer")
        described_class.create(submitter: "test@default.invalid", payload: [collection.id])
        transfers = described_class.with_submitter("test@default.invalid")
        expect(transfers.all.size).to eq(1)
        expect(transfers.all.first.payload.first).to eq(collection.id)
      end
    end

    describe ".payload=" do
      it "requires `payload` to be an Array" do
        transfer = described_class.new(submitter: "test@default.invalid")
        expect do
          transfer.payload = 123
        end.to raise_exception(/must be an Array/)
      end
    end

    describe ".submitter_usernames" do
      it "returns the Array it was initialized with" do
        transfer = described_class.create(submitter: "test@default.invalid", submitter_usernames: ["test@default.invalid"])
        expect(transfer.submitter_usernames).to be_a(Array)
      end
    end

    describe ".submitter_usernames=" do
      it "requires `submitter_usernames` to be an Array" do
        transfer = described_class.new(submitter: "test@default.invalid")
        expect do
          transfer.submitter_usernames = "somebody@default.invalid"
        end.to raise_exception(/must be an Array/)
      end
    end
  end
end
