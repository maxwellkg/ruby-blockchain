require 'rails_helper'

describe Blockchain do

  describe "ensure validity" do

    it "should be valid on creation" do
      Blockchain.instance.valid?.should be_true
    end

    it "should ensure all blocks are valid" do
      bl = Blockchain.instance.blocks.first
      bl.nonce = 0

      Blockchain.instance.valid?.should be_false
    end

    it "should ensure all blocks are linked" do
      raise NotImplementedError
    end

    it "should ensure all blocks are linked" do
      raise NotImplementedError
    end

    it "should ensure all spends are valid" do
      raise NotImplementedError
    end

    it "should validate the coin supply" do
      raise NotImplementedError
    end

  end

end