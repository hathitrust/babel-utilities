# frozen_string_literal: true

require "sequel"

module Babel::Operation
  RSpec.describe(TransferCollection) do
    # Some user ids
    let(:old_identity) { "my_old_identity" }
    let(:new_identity) { "my_new_identity" }
    let(:old_name) { "my_old_name@default.invalid" }
    let(:other_name) { "my_other_name@default.invalid" }
    let(:someone_else) { "someone_else@default.invalid" }
    # Some collections owned by the user
    let!(:my_collection_abc) {
      Babel::Model::MBCollection.create(owner: old_identity, owner_name: other_name, name: "My Collection ABC")
    }
    let!(:my_collection_def) {
      Babel::Model::MBCollection.create(owner: old_identity, owner_name: old_name, name: "My Collection DEF")
    }
    # A collection not owned by the user
    let!(:someone_elses_collection) {
      Babel::Model::MBCollection.create(owner: someone_else, name: "Someone Else's Collection")
    }
    # An unknown collection id
    # TODO: create dynamically as max + 1?
    let(:unknown_collection_id) { 0 }
    # A transfer for collection ABC
    let!(:my_pending_transfer) {
      Babel::Model::MBTransfer.create(submitter: old_identity, receiver: new_identity, payload: [my_collection_abc.id])
    }
    # TransferCollection objects for all, and for an everyrhing-and-the-kitchen-sink payload
    let(:transfer_all) { described_class.new(from: old_identity, to: new_identity, all: true) }
    let(:transfer_payload) {
      described_class.new(
        from: old_identity,
        to: new_identity,
        collections: [
          my_collection_abc.id,
          my_collection_def.id,
          someone_elses_collection.id,
          unknown_collection_id
        ]
      )
    }

    describe "#new" do
      context "with payload" do
        it "considers only the payload collections" do
          expect(transfer_payload.candidates.count).to eq(4)
        end
      end

      context "with `all` param" do
        it "identifies all of the user's collections as candidates" do
          expect(transfer_all.candidates.count).to eq(4)
        end
      end
    end

    describe ".unknown_collections" do
      it "identifies an unknown collection" do
        expect(transfer_payload.unknown_collections).to eq([unknown_collection_id])
      end

      it "does not produce false positives" do
        expect(transfer_all.unknown_collections).to eq([])
      end
    end

    describe ".restricted_collections" do
      it "identifies a collection not owned by the user" do
        expect(transfer_payload.restricted_collections).to eq([someone_elses_collection.id])
      end
    end

    describe ".pending_collections" do
      it "identifies a collection that already has a transfer" do
        expect(transfer_payload.pending_collections).to eq([my_collection_abc.id])
      end
    end

    describe ".allowed_collections" do
      it "identifies only those collections that are exist, are owned, and not pending" do
        expect(transfer_payload.allowed_collections).to eq([my_collection_def.id])
      end
    end

    describe ".submitter_usernames" do
      it "extracts all and only the `owner` and `owner_name` values" do
        expect(transfer_payload.submitter_usernames).to eq([old_identity, old_name].sort)
      end
    end

    describe ".mb_transfer" do
      it "returns a Babel::Model::MBTransfer with the expected values" do
        expect(transfer_payload.mb_transfer).to be_a(Babel::Model::MBTransfer)
        expect(transfer_payload.mb_transfer.submitter).to eq(transfer_payload.from)
        expect(transfer_payload.mb_transfer.submitter_usernames).to eq(transfer_payload.submitter_usernames)
        expect(transfer_payload.mb_transfer.receiver).to eq(new_identity)
        expect(transfer_payload.mb_transfer.payload).to eq(transfer_payload.allowed_collections)
      end
    end

    describe ".run!" do
      it "returns a token" do
        expect(transfer_payload.run!).to match(/[0-9A-Za-z-]{36}/)
      end
    end
  end
end
