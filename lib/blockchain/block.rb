module Blockchain
  class Block
    include ActiveModel::Model

    validate :nonce_must_be_valid, :transactions_must_be_valid

    NUM_ZEROES = 4.freeze

    attr_reader :own_hash, :prev_block_hash, :transactions, :miner, :nonce

    def self.create_genesis_block(pub_key, priv_key)
      genesis_transaction = Transaction.new(nil, pub_key, Coin::GENESIS_AMT, priv_key, 0)
      genesis_block = Block.new(nil, [genesis_transaction])

      genesis_block.mine!
      genesis_block
    end

    def initialize(prev_block, transactions = [])
      @transactions = transactions
      @prev_block_hash = prev_block.own_hash if prev_block

      @prev_block_hash = prev_block ? prev_block.own_hash : ('0' * 64)
    end

    def genesis_block?
      @prev_block_hash.nil?
    end

    def mine!
      @miner = Client.instance.pub_key
      @nonce = find_nonce
      @own_hash = hash(full_block(@nonce))
    end

    def full_block(nonce)
      [@prev_block_hash, @miner, @transactions, nonce].compact.join
    end

    def find_nonce
      nonce = 0

      until is_valid_nonce?(nonce)
        nonce += 1
      end

      nonce
    end

    # can this be moved under private?
    def is_valid_nonce?(nonce)
      hash(full_block(nonce)).start_with?('0' * NUM_ZEROES)
    end

    def previous
      Blockchain.instance.find(prev_block_hash)
    end

    private

      def hash(contents)
        Digest::SHA256.hexdigest(contents)
      end

      def nonce_must_be_valid
        errors.add(:nonce, 'Nonce must be set so that the hash of the block begins with #{NUM_ZEROES} zeroes') unless is_valid_nonce?(@nonce)
      end

      def transactions_must_be_valid
        errors.add(:transaction_type, 'Not all transactions are of type Transaction') unless @transactions.all? { |t| t.is_a?(Transaction) }
        errors.add(:valid_transaction, 'Not all transactions are valid') unless @transactions.all?(&:valid?)
      end

  end
end