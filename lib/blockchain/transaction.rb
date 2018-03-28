module Blockchain
  class Transaction
    include ActiveModel::Model

    validate :signature_must_be_valid

    attr_reader :from, :to, :amount, :tip

    def initialize(from, to, amount, priv_key, tip = 0)
      @from, @to, @amount, @tip = from, to, amount, tip

      @signature = PKI.sign(message, priv_key)
    end

    def genesis_transaction?
      # the genesis transaction will be the only transaction included in the first block
      # on the chain
      self == Blockchain.instance.blocks.first.transactions.first
    end

    def add_to_pool
      TransactionPool.instance.add_transaction!(self)
    end

    def message
      Digest::SHA256.hexdigest([@from, @to, @amount].join)
    end

    def where(conditions)
      Blockchain.instance.blocks.select do |b|
        conditions.each { |att, val| b.transaction.send(att) == val }.all?
      end
    end

    def total
      amount + tip
    end

    private

      def signature_must_be_valid
        unless is_valid_signature?
          errors.add(:signature, 'Signature must be valid')
        end
      end

      def is_valid_signature?
        # the genesis transaction is always valid
        return true if genesis_transaction?

        PKI.valid_signature?(message, @signature, from)
      end

  end
end