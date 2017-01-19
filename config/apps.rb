Padrino.configure_apps do
  enable :sessions
  set :session_secret, '52cb066050f4e1bef0802bef111939d64969136a6774f7d34f26f682cf4e10e9'
  set :protection, :except => :path_traversal
  #set :protect_from_csrf, true
  #set :protect_from_csrf, except: %r{/__better_errors/\w+/\w+\z} if Padrino.env == :development
  ### app specific settings, you can access them like this: settings.auth[:twitter][:key] ###
  # single sign on credentials
  set :auth, {
        :twitter => {:key => '', :secret => ''},
        :instagram => {:key => '', :secret => ''}
      }

  set :filepicker, 'ACGRkMPr9TqmbgPiHBS5Cz'


  case Padrino.env
  when :development
    set :base_url, "http://shalendar.docker"
    Instagram.configure do |config|
      config.client_id = "79756588aba4487e9c3947a6f033db0d"
      config.client_secret = "c77405cd424847cb921873c2e15ceb29"
    end
  else
    set :base_url, "https://www.shalendar.com"
    Instagram.configure do |config|
      config.client_id = "YOUR_CLIENT_ID"
      config.client_secret = "YOUR_CLIENT_SECRET"
    end
  end

end



# Mounts the core application for this project
Padrino.mount('Honeybadger::AdminApp', :app_file => Padrino.root('app/admin/app.rb')).to('/admin')
Padrino.mount('Honeybadger::SiteApp', :app_file => Padrino.root('app/site/app.rb')).to('/')
