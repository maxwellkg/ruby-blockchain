class Blockchain

  attr_reader :blocks

  def self.instance
    @@instance ||= self.new
  end

  def initialize
    @blocks = []
    @blocks << Block.create_genesis_block(Client.instance.pub_key, Client.instance.priv_key)
  end

  def valid?
    return false if !@blocks.all? { |b| b.is_a?(Block) }
    return false if !@blocks.all?(&:valid?)
    return false if !is_genesis? && @blocks.each_cons(2).all? { |a, b| a.own_hash == b.prev_block_hash }
    return false if !all_spends_valid?

    true
  end

  def is_genesis?
    length == 1
  end

  def all_spends_valid?
    compute_balances do |balances, from, to|
      return false if balances.values_at(from, to).any? { |bal| bal < 0 }
    end

    true
  end

  def compute_balances
    genesis_transaction = @blocks.first.transaction
    balances = {}
    balances.default = 0

    @blocks.each_with_index do |block, index|
      from = block.transaction.from
      to = block.transaction.to
      amount = block.transaction.amount

      balances[from] -= amount unless index == 0
      balances[to] += amount

      yield balances, from, to if block_given?
    end

    balances
  end

  def add_to_chain!(transaction)
    raise TypeError unless transaction.is_a?(Transaction)

    @blocks << Block.new(@blocks.last, transaction)
  end

  def length
    @blocks.length
  end

  def update!(peer_blockchain)
    return if peer_blockchain.nil?
    return if peer_blockchain.length <= length
    return unless peer_blockchain.valid?

    @blocks = peer_blockchain.blocks
    self
  end

  def find(hash)
    found = nil

    @blocks.each do |b|
      if b.own_hash == hash
        found = b
        break
      end
    end

    found
  end

end
