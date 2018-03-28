module Blockchain
  class TransactionPool

    BLOCKS_TO_CONFIRMATION = 10.freeze

    attr_reader :transactions

    def self.instance
      @@instance ||= self.new
    end

    def initialize(pending: [], unconfirmed: [], confirmed: [])
      @transactions = { pending: pending, unconfirmed: unconfirmed, confirmed: confirmed }
    end

    def add_transaction!(transaction, category: :pending)
      raise "Not a valid transaction!" unless transaction.valid?

      @transactions[category] << transaction
    end

    def update_pool!(their_pool: nil)
      if their_pool
        [:pending, :unconfirmed].each do |key|
          @transactions[key] = @transactions[key].push(their_pool[key]).uniq
        end
      end

      mark_unconfirmed_transactions!
      mark_confirmed_transactions!
      remove_completed_transactions!
    end

    private

      def mark_confirmed_transactions!
        msgs = Blockchain.instance.blocks.map { |block| block.transactions.map(&:message) }.flatten

        transactions[:unconfirmed].each do |ut|
          if msgs.index(ut.own_hash).try(:<=, hashes.length - 10)
            transactions[:confirmed] << ut
          end
        end

        transactions[:unconfirmed].delete_if { |t| transactions[:confirmed].include?(t) }
      end

      def mark_unconfirmed_transactions!
        msgs = Blockchain.instance.blocks.map { |block| block.transactions.map(&:message) }.flatten

        transactions[:pending].each do |pt|
          if msgs.index(pt.own_hash).try(:>, hashes.length - 10)
            transactions[:unconfirmed] << pt
          end
        end

        transactions[:pending].delete_if { |t| transactions[:unconfirmed].include?(t) }
      end

      def remove_completed_transactions!
       transactions[:confirmed] = []
      end

  end
end