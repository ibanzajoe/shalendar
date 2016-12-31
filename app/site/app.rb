# This is the main router file
# You can also create your own controllers in app/controllers/

module Honeybadger

  class SiteApp < Padrino::Application

    register Padrino::Mailer
    register Padrino::Helpers
    register WillPaginate::Sinatra
    enable :sessions
    enable :reload
    layout :site


    ### this runs before all routes ###
    before do
      @title = "Shalendar | Digital Calendar for your life"
      @page = (params[:page] || 1).to_i
      @per_page = params[:per_page] || 5
      @current_user = session[:user] if !session[:user].blank?
    end

    ### authentication routes ###
    auth_keys = settings.auth # @todo: settings is not available in Builder

    use OmniAuth::Builder do

      # /auth/twitter
      provider :twitter,  auth_keys[:twitter][:key], auth_keys[:twitter][:secret]

      # /auth/instagram
      provider :instagram,  auth_keys[:instagram][:key], auth_keys[:instagram][:secret]

    end

    get '/auth/:name/callback' do
      auth    = request.env["omniauth.auth"]
      user = User.login_with_omniauth(auth)

      if user
        session[:user] = user

        if user.email.blank?
          redirect("/user/account", :notice => 'Please fill in required informations')
        end

        redirect("/")
      else
        output(user.values)
      end
    end

    get "/user/account" do
      @user = session[:user]

      render "account"
    end

    post "/user/account" do

      rules = {
        :email => {:type => 'email', :required => true},
        :first_name => {:type => 'string', :required => true},
        :last_name => {:type => 'string', :required => true},
      }
      validator = Validator.new(params, rules)

      @user = session[:user]
      @user.email = params[:email]
      @user.first_name = params[:first_name]
      @user.last_name = params[:last_name]

      if !validator.valid?
        flash.now[:notice] = validator.errors[0][:error]
        render "account"
      else
        @user.save_changes
        redirect("/user/account", :success => 'Account information updated!')
      end

    end

    get "/user/login" do
      render "login", :layout => 'site'
    end

    post "/user/login" do

      rules = {
        :email => {:type => 'email', :required => true},
        :password => {:type => 'string', :required => true},
      }
      validator = Validator.new(params, rules)
      if !validator.valid?
        flash.now[:notice] = validator.errors[0][:error]
        render "login"
      else
        user = User.login(params)
        if user.errors.empty?
          session[:user] = user
          flash[:success] = "You are now logged in"
          redirect("/#{user[:username]}")
        else
          flash.now[:notice] = user.errors[:validation][0]
          render "login"
        end
      end

    end

    get "/user/logout" do
      session.delete(:user)
      redirect("/")
    end

    get "/user/register" do
      render "register"
    end

    post "/user/register" do

      rules = {
        :first_name => {:type => 'string', :required => true},
        :last_name => {:type => 'string', :required => true},
        :email => {:type => 'email', :required => true},
        :password => {:type => 'string', :required => true},
      }
      validator = Validator.new(params, rules)
      if !validator.valid?
        flash.now[:notice] = validator.errors[0][:error]
        render "register"
      else

        user = User.register_with_email(params)
        if user.errors.empty?
          session[:user] = user
          redirect("/user/account")
        else
          flash.now[:notice] = user.errors[:validation][0]
          render "register"
        end

      end

    end


    ### put your routes here ###
    get '/' do
      render "index"
    end

    get '/about' do
      render "about"
    end

    get '/features' do
      render "features"
    end

    get '/pricing' do
      render "pricing"
    end

    get '/error' do
      render "error"
    end

    ### calendar page ###
    get '/:username' do
      @user = User.where(:username => params[:username]).first
      if @user.blank?
        return "error"
      end
      render "user_calendar", :layout => "calendar"
    end

    ### get a list of calendars
    ### params: user_id
    get '/api/calendars' do
      content_type :json

      res = []
      res << { :id => nil, :name => 'all', :total_events => Event.where(:calendar_id => nil, :user_id => params[:user_id]).count }
      calendars = Calendar.where(:user_id => params[:user_id]).all
      calendars.each {|row|

        item = row.values
        item[:total_events] = Event.where(:calendar_id => row[:id], :user_id => params[:user_id]).count
        
        res << item
        p '--calendar loop--'
        p "#{row[:calendar_id]}: #{item[:total_events]}"

      }

      if !res.blank?
        
        return res.to_json
      else
        return { :code => 404, :status => 'no calendars' }.to_json
      end
    end

    ### create a calendar
    ### params: user_id, name
    post '/api/calendar' do
      content_type :json

      colors = Calendar.colors
      data = {
        :user_id => params[:user_id],
        :name => params[:name],
        :color => colors.sample
      }
      calendar = Calendar.create(data)
      return {
        :calendar => calendar,
        :code => 200
      }.to_json
    end

    ### get a list of events
    ### params: user_id
    ### optional: calendar_id
    get '/api/events' do
      content_type :json
      conditions = { :user_id => params[:user_id] }

      p 'params'
      p params

      if !params[:calendar_id].blank?
        calendar = Calendar.where(:user_id => params[:user_id], :id => params[:calendar_id]).first
        p 'calendar'
        p calendar
        conditions[:calendar_id] = calendar[:id] if calendar
      end

      starts_at = params[:start] || Date.today.at_beginning_of_month
      ends_at = params[:end] || Date.today.at_beginning_of_month.next_month
      events = Event.where(conditions).where('ends_at >= ?', starts_at).where('ends_at <= ?', ends_at).all

      p 'events sql'
      p Event.where(conditions).where('ends_at >= ?', starts_at).where('ends_at <= ?', ends_at)

      p 'conditions'
      p conditions

      res = []
      events.each {|event|
        res << event.formatted.values.except(:starts_at, :ends_at)
      }

      p res
      return res.to_json

    end


    ### get a list of events
    ### params: id
    ### optional: calendar_id
    get '/api/event' do
      content_type :json
      event = Event.where(:id => params[:id]).first
      if event
        res = event.formatted.values
      end
      return res.to_json
    end


    ### create an event
    ### params: title, start
    ### note: user_id (taken from session)
    ### optional: id, calendar_id, end, url, description
    post '/api/event' do
      content_type :json

      color = '#ffffff'
      if !params[:calendar_id].blank?
        calendar = Calendar[params[:calendar_id]]
        color = calendar[:color]
      end

      data = {
        :user_id => @current_user[:id],
        :calendar_id => params[:calendar_id] || nil,
        :title => params[:title],
        :starts_at => params[:start],
        :ends_at => params[:end] || params[:start],
        :url => params[:url],        
        :color => color,
        :description => params[:description],
        :location => params[:location],        
        :media => params[:media].to_json,        
      }

      if !params[:id].blank?
        event = Event[params[:id]]
        if event
          event.update(data)
        end
      else
        event = Event.create(data)
      end

      res = event.formatted.values.to_json
      return res
    end



    ### create an event
    ### params: id
    post '/api/event/delete' do
      content_type :json

      event = Event.where(:id => params[:id]).first
      if event
        event.destroy
        res = {
          :status => 'deleted',
          :code => 200
        }
      else
        res = {
          :status => 'event not found',
          :code => 404
        }
      end

      return res.to_json
    end


    post '/api/login' do

      content_type :json

      rules = {
        :email => {:type => 'email', :required => true},
        :password => {:type => 'string', :required => true},
      }

      validator = Validator.new(params, rules)
      if !validator.valid?
        res = {
          :status => 'input validation failure',
          :code => 403,
          :error => validator.errors,
        }
      else
        user = User.login(params)
        if user.errors.empty?
          session[:user] = user

          res = {
            :status => 'auth success',
            :code => 200,
            :redir => "/#{user[:username]}",
          }

        else

          res = {
            :status => 'authentication failure',
            :code => 401,
            :error => user.errors,
          }

        end
      end

      res.to_json

    end

    post '/api/register' do

      content_type :json

      rules = {
          :email => {:type => 'email', :required => true},
          :password => {:type => 'string', :required => true},
      }

      validator = Validator.new(params, rules)
      if !validator.valid?
        res = {
            :status => 'input validation failure',
            :code => 403,
            :error => validator.errors,
        }
      else
        user = User.register_with_email(params)
        if user.errors.empty?
          session[:user] = user

          res = {
              :status => 'auth success',
              :code => 200,
              :redir => "/#{user[:username]}",
          }

        else

          res = {
              :status => 'authentication failure',
              :code => 401,
              :error => user.errors,
          }

        end
      end

      res.to_json

    end


  end

end
