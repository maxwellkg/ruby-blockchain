class Block
  include ActiveModel::Model

  GENESIS_AMT = 10_000_000.freeze
  NUM_ZEROES = 4.freeze

  attr_reader :own_hash, :prev_block_hash, :transaction

  def self.create_genesis_block(pub_key, priv_key)
    genesis_transaction = Transaction.new(nil, pub_key, GENESIS_AMT, priv_key)
    Block.new(nil, genesis_transaction)
  end

  def initialize(prev_block, transaction)
    raise TypeError unless transaction.is_a?(Transaction)
    @transaction = transaction
    @prev_block_hash = prev_block.own_hash if prev_block

    mine!
  end

  def valid?
    is_valid_nonce?(@nonce) && transaction.is_valid_signature?
  end

  def genesis_block?
    @prev_block_hash.nil?
  end

  def mine!
    @nonce = find_nonce
    @own_hash = hash(full_block(@nonce))
  end

  def full_block(nonce)
    [@prev_block_hash, @transaction.to_s, nonce].compact.join
  end

  def find_nonce
    nonce = 0

    until is_valid_nonce?(nonce)
      nonce += 1
    end

    nonce
  end

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

end
