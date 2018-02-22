class BlockchainController < ApplicationController

  def main
    @blockchain = Blockchain.instance
  end

  # @param blockchain
  # @param peers
  def gossip
    their_blockchain = YAML.load(params['blockchain'])
    their_peers = YAML.load(params['peers'])

    Blockchain.instance.update!(their_blockchain)
    Client.instance.update_peers!(their_peers)

    render plain: YAML.dump('peers' => Client.instance.peers, 'blockchain' => Blockchain.instance)
  end

  def public_key
    render plain: Client.instance.pub_key
  end

  private

    def blockchain_params
      params.permit(:blockchain, :peers)
    end

    def transfer_params
      params.permit(:to, :amount)
    end

    def own_peers
      Blockchain.instance.peers
    end

    def own_blockchain
      Blockchain.instance.blockchain
    end


end
