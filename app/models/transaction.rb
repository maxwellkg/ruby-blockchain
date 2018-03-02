class Transaction
  include ActiveModel::Model

  validate :signature_must_be_valid

  attr_reader :from, :to, :amount

  def initialize(from, to, amount, priv_key)
    @from, @to, @amount = from, to, amount

    @signature = PKI.sign(message, priv_key)
  end

  def genesis_transaction?
    # the genesis transaction will be the only transaction included in the first block
    # on the chain

    self == Blockchain.instance.blocks.first.transactions.first
  end

  def message
    Digest::SHA256.hexdigest([@from, @to, @amount].join)
  end

  def where(conditions)
    Blockchain.instance.blocks.select do |b|
      conditions.each { |att, val| b.transaction.send(att) == val }.all?
    end
  end

  def self.all
    Blockchain.instance.blocks.map(&:transaction)
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
