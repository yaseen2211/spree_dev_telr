Spree::Core::Engine.add_routes do
  # Add your extension routes here
    post '/telr', :to => "telr#express", :as => :telr_v2

    get '/telr_r_auth', :to => "telr#receiver_authorized_transactions", :as => :telr_v2_authorized
    get '/telr_r_can', :to => "telr#receiver_decl_transactions", :as => :telr_v2_declined
    get '/telr_r_decl', :to => "telr#receiver_cancelled_transactions", :as => :telr_v2_cancelled

end
