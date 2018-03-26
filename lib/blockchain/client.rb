module Blockchain
  class Client
    include Singleton

    URL = "http://localhost".freeze

    attr_reader :priv_key, :pub_key
    attr_accessor :peers

    def initialize
      yaml_config = YAML.load(File.read('config/blockchain.yml'))

      # if a key pair is provided in the configuration, use it
      # otherwise, create a new pair
      if yaml_config.values_at('client_private_key', 'client_public_key').any?(&:nil?)
        @priv_key, @pub_key = PKI.generate_key_pair
      else
        @priv_key, @pub_key = yaml_config.values_at('client_private_key', 'client_public_key')
      end

      @peers = yaml_config['peers'] || []
      @own_port = yaml_config['port']
    end

    def gossip
      return if @peers.nil?

      @peers.dup.each do |port|
        # skip own port
        next if port == @own_port

        gossip_with_peer(port)
      end
    end

    def get_pub_key(port)
      Faraday.get("#{URL}:#{port}/public_key").body
    end

    def send_money(port, to, amount)
      Faraday.post("#{URL}:#{port}/send_money", to: to, amount: amount).body
    end

    def update_peers!(their_peers)
      @peers = (@peers + their_peers).uniq
    end

    private

      def gossip_with_peer(port)
        begin
          gossip_response = begin
                              Faraday.post("#{URL}:#{port}/gossip", peers: YAML.dump(@peers), blockchain: YAML.dump(Blockchain.instance)).body
                            rescue Faraday::ConnectionFailed => e
                              raise
                            end

          parsed_response = YAML.load(gossip_response)

          their_peers = parsed_response['peers']
          their_blockchain = parsed_response['blockchain']

          update_peers!(their_peers)
          Blockchain.instance.update!(their_blockchain)
        rescue ::Faraday::ConnectionFailed => e
          @peers.delete(port)
        end
      end

  end
end