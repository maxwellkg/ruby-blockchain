class TransactionPool
  include Singleton

  BLOCKS_TO_CONFIRMATION = 10.freeze

  attr_reader :transactions

  # @param transactions, a hash with keys: Pending, Unconfirmed, Confirmed
  def initialize(transactions = {})
    @transactions = transactions
  end

  def add_transaction!(transaction)
    raise "Not a valid transaction!" unless transaction.valid?

    @transactions << transaction
  end

  def update_pool!(their_pool)
    # first, we'll want to update the pool with new transactions from peers

    # then we'll want to handle transactions that have already been added to the chain
    remove_completed_transactions!
  end

  def remove_completed_transactions!
    # there are two categories here
    # first, are "unconfirmed" transactions, those that are on the chain but that are not far enough back
    # to be considered as confirmed
    # second, there are those that are far enough back on the chain that we can consider them as having
    # a sufficiently improbable chance of being changed
    # FOR THE TIME BEING, we will consider 10 blocks as an adequate length
   
  end

  def mark_unconfirmed_transactions!

  end

  def mark_confirmed_transactions!
    
  end

end