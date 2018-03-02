class Block
  include ActiveModel::Model

  validate :nonce_must_be_valid, :transactions_must_be_valid

  GENESIS_AMT = 10_000_000.freeze
  NUM_ZEROES = 4.freeze

  attr_reader :own_hash, :prev_block_hash, :transactions

  def self.create_genesis_block(pub_key, priv_key)
    genesis_transaction = Transaction.new(nil, pub_key, GENESIS_AMT, priv_key)
    genesis_block = Block.new(nil, [genesis_transaction])

    genesis_block.mine!
    genesis_block
  end

  def initialize(prev_block, transactions = [])
    @transactions = transactions
    @prev_block_hash = prev_block.own_hash if prev_block
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
      unless is_valid_nonce?(@nonce)
        errors.add(:nonce, 'Nonce must be set so that the hash of the block begins with #{NUM_ZEROES} zeroes')
      end
    end

    def transactions_must_be_valid
      errors.add(:transaction_type, 'Not all transactions are of type Transaction') unless @transactions.all? { |t| t.is_a?(Transaction) }
      
      @transactions.each do |t|
        unless t.valid?
          errors.add(:valid_transaction, 'Not all transactions are valid')
          break
        end
      end
    end

end
