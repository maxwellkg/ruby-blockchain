Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'blockchain#main'

  post 'gossip', to: 'blockchain#gossip'
  get 'public_key', to: 'blockchain#public_key'
  post 'send_money', to: 'blockchain#send_money'
end
