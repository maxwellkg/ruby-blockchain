module Coin

  GENESIS_AMT = 10_000_000
  MAX_AMT = 100_000_000
  HEIGHT_AT_MAX_AMT = 20_000_000

  def self.reward_at(height)
    return 0 if height == 0
    
    coins_at(height) - coins_at(height - 1)
  end

  def self.coins_at(height)
    return GENESIS_AMT if height < 0

    [(2 * Math.sqrt(101250000 * height) + GENESIS_AMT).floor, MAX_AMT].min
  end

end
