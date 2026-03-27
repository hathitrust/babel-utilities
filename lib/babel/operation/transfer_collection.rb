# frozen_string_literal: true

module Babel::Operation
  class TransferCollection
    attr_reader :from, :to, :candidates, :noop

    def initialize(from:, to:, all: false, collections: [])
      @from = from
      @to = to
      @all = all # FIXME: needed?
      @candidates = if all
        Babel::Model::MBCollection.where(owner: from).map do |coll|
          coll.id
        end
      else
        collections
      end
      @noop = noop
    end

    # The collection ids that do not exist
    def unknown_collections
      @unknown_collections ||= candidates - Babel::Model::MBCollection.with_ids(candidates).map(&:id)
    end

    # Candidates that are not owned by the `from` user and thus cannot be transferred
    def restricted_collections
      @restricted_collections ||= candidates - Babel::Model::MBCollection.where(owner: from).map(&:id) - unknown_collections
    end

    # Candidates that are already in the payload of one of the `from` user's existing transfers
    def pending_collections
      @pending_collections ||= candidates & all_pending_transfers
    end

    # ids of the collections that exist, are owned by the user, and do not have pending transfers
    def allowed_collections
      @allowed_transfers ||= candidates - unknown_collections - restricted_collections - pending_collections
    end

    # Collects up all of the owner and owner_name fields from available collections
    # and returns sorted unique values
    def submitter_usernames
      @submitter_usernames ||= Babel::Model::MBCollection.with_ids(allowed_collections).map do |collection|
        [collection.owner, collection.owner_name]
      end.flatten.uniq.sort
    end

    # Initialize the new model but do not save it yet, pending inspection.
    def mb_transfer
      @mb_transfer ||= Babel::Model::MBTransfer.new(
        submitter: from,
        submitter_usernames: submitter_usernames,
        receiver: to,
        payload: allowed_collections
      )
    end

    # Returns the new tokwn
    def run!
      mb_transfer.save
      mb_transfer.token
    end

    private

    def all_pending_transfers
      @all_pending_transfers = Babel::Model::MBTransfer.with_submitter(from)
        .map(&:payload)
        .flatten
        .uniq
    end
  end
end
