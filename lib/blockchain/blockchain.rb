module Blockchain
  class Blockchain
    include ActiveModel::Model

    validate :blocks_are_blocks?, :blocks_are_valid?, :blocks_are_linked?, :all_spends_valid?
    validate :valid_coin_supply?, :all_hashes_are_unique?

    attr_reader :blocks

    def self.instance
      @@instance ||= self.new
    end

    def initialize
      @blocks = []
      @blocks << Block.create_genesis_block(Client.instance.pub_key, Client.instance.priv_key)
    end

    def is_genesis?
      length == 1
    end

    def compute_balances
      balances = Hash.new(0)

      @blocks.each_with_index do |block, index|
        block.transactions.each do |t|
          from = t.from
          to = t.to

          balances[from] -= t.total unless index == 0
          balances[to] += t.amount
          balances[block.miner] += t.tip unless index == 0

          yield index, balances, from, to if block_given?
        end

        balances[block.miner] += Coin.reward_at(index)
      end

      balances
    end

    def add_to_chain!(block)
      raise TypeError unless block.is_a?(Block)
      raise "Block is not valid!" unless block.valid?

      @blocks << block
      TransactionPool.instance.update_pool!

      self
    end

    def length
      @blocks.length
    end

    def height
      length - 1
    end

    def coins_outstanding
      compute_balances.values.sum
    end

    def update!(peer_blockchain)
      return if peer_blockchain.nil?
      return if peer_blockchain.length <= length
      return unless peer_blockchain.valid?

      @blocks = peer_blockchain.blocks
      self
    end

    def find(hash)
      @blocks.detect { |b| b.own_hash == hash }
    end

    def transactions
      @blocks.collect { |b| b.transactions }.flatten
    end

    private

      def blocks_are_blocks?
        errors.add(:block_blocks, 'All blocks are not blocks') unless @blocks.all? { |b| b.is_a?(Block) }
      end

      def blocks_are_valid?
        errors.add(:valid_blocks, 'All blocks are not valid') unless @blocks.all?(&:valid?)
      end

      def blocks_are_linked?
        unless is_genesis? || @blocks.each_cons(2).all? { |a, b| b.prev_block_hash == a.own_hash }
          errors.add(:linked_blocks, 'All blocks are not properly linked')
        end
      end

      def all_spends_valid?
        compute_balances do |_, balances, from, to|
          spends_valid = true

          if balances.values_at(from, to).any? { |bal| bal < 0 }
            errors.add(:valid_spends, 'Not all spends are valid')
            break
          end
        end
      end

      def valid_coin_supply?
        compute_balances do |height, balances, _, _|
          errors.add(:coin_supply, 'Coin supply is invalid') if balances.values.sum > Coin.coins_at(height - 1)
        end
      end

      def all_hashes_are_unique?
        hashes = @blocks.map(&:own_hash)
        hashes.uniq.length == hashes.length
      end

  end
end
