class Transaction
  include ActiveModel::Model

  attr_reader :from, :to, :amount

  def initialize(from, to, amount, priv_key)
    @from, @to, @amount = from, to, amount

    @signature = PKI.sign(message, priv_key)
  end

  def is_valid_signature?
    # the genesis transaction is always valid
    return true if genesis_transaction?

    PKI.valid_signature?(message, @signature, from)
  end

  def genesis_transaction?
    self == Blockchain.instance.blocks.first.transaction
  end

  def message
    Digest::SHA256.hexdigest([@from, @to, @amount].join)
  end

end
