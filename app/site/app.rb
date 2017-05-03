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

      if !session[:user_id].blank?
        @current_user = User[session[:user_id]]
      end

      Instagram.configure do |config|
        config.client_id = settings.auth[:instagram][:key]
        config.client_secret = settings.auth[:instagram][:secret]
      end

      if !@current_user[:integrations].blank? && !@current_user[:integrations]["instagram"].blank?
        @instagram = Instagram.client(:access_token => @current_user[:integrations]["instagram"]["access_token"])
      end
    end

    ### authentication routes ###
    auth_keys = settings.auth # @todo: settings is not available in Builder

    use OmniAuth::Builder do

      # /auth/twitter
      provider :twitter,  auth_keys[:twitter][:key], auth_keys[:twitter][:secret]

      # /auth/instagram
      provider :instagram,  auth_keys[:instagram][:key], auth_keys[:instagram][:secret]

    end

    get '/beta' do
      render "login", :layout => 'beta'
    end

    get '/auth/:name/callback' do
      auth    = request.env["omniauth.auth"]
      user = User.login_with_omniauth(auth)

      if user
        integrations = @current_user[:integrations] || {}
        integrations[user.provider] = {:user_id => user.id }
        @current_user.update(:integrations => integrations.to_json).reload

        # if user.email.blank?
        #   redirect("/user/account", :notice => 'Please fill in required informations')
        # end

        # redirect("/")
      else
        output(user.values)
      end
    end

    get '/connect/instagram' do
      redirect Instagram.authorize_url(:redirect_uri => "#{settings.base_url}/cb/instagram")
    end

    get '/cb/instagram' do
      response = Instagram.get_access_token(params[:code], :redirect_uri => "#{settings.base_url}/cb/instagram")

      user_id = session[:user_id]
      user = User[user_id]

      integrations = user[:integrations] || {}
      integrations["instagram"] = { :access_token => response.access_token }

      user[:integrations] = integrations.to_json
      user.save.reload

      redirect "/sync/instagram"
    end

    get '/sync/instagram' do

      calendar = Calendar.where(:name => "Instagram", :user_id => @current_user[:id]).first

      calendar = Calendar.create(:user_id => @current_user[:id], :name => "Instagram", :color => Calendar.colors.sample) if calendar.blank?

      Thread.new {
        instagram = Shalendar::Instagram.new(@instagram)
        res = instagram.sync(@current_user, calendar)
      }

      redirect "/#{@current_user[:username]}"
    end

    get "/user/account" do
      # @user = session[:user]
      # render "account"
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

    get "/login" do
      render "login", :layout => 'beta'
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
          session[:user_id] = user[:id]
          flash[:success] = "You are now logged in"
          redirect("/#{user[:username]}")
        else
          flash.now[:notice] = user.errors[:validation][0]
          render "login"
        end
      end

    end

    get "/user/logout" do
      session.destroy
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
          session[:user_id] = user[:id]
          redirect("/user/account")
        else
          flash.now[:notice] = user.errors[:validation][0]
          render "register"
        end

      end

    end


    ### put your routes here ###
    get '/' do
      if !@current_user.blank?
        redirect "/#{@current_user.username}"
      end
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

      color = params[:color] || Calendar.colors.sample

      data = {
        :user_id => params[:user_id],
        :name => params[:name],
        :color => color
      }

      if params[:id].blank?
        calendar = Calendar.create(data)
      else
        calendar = Calendar.where(:id => params[:id]).first
        calendar.update(data)
      end

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

      res = []
      events.each {|event|
        data = event.formatted.values.except(:starts_at, :ends_at)
        data[:color] = Calendar[event[:calendar_id]][:color] || Calendar.colors[0]
        res << data
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

      color = Calendar.colors[0]
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
          session[:user_id] = user[:id]

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
          session[:user_id] = user[:id]

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

    post '/api/follow/:username' do

      content_type :json

      friend = User.where(:username => params[:username]).first
      return { :status => 'error', :code => 400, :msg => 'cant follow yourself'}.to_json if friend.id == @current_user.id
      begin

        user_follow = UserFollow.create(:user_id => @current_user.id, :friend_id => friend.id)
        res = {
          :status => 'ok',
          :code => 200,
          :friend => friend,
        }

      rescue => e
        res = {
          :status => 'error',
          :code => 500,
          :msg => 'duplicate relation'
        }
      end

      res.to_json

    end


    post '/api/unfollow/:username' do

      content_type :json
      friend = User.where(:username => params[:username]).first

      userfollow = UserFollow.where(:user_id => @current_user.id, :friend_id => friend.id).destroy
      if userfollow == 1
        res = {
          :status => 'ok',
          :code => 200,
        }
      else
        res = {
          :status => 'error',
          :code => 500,
          :msg => 'user not following'
        }
      end
      res.to_json

    end

    get '/api/friends' do
      friends = UserFollow.where(:user_id => @current_user.id).all

      content_type :json
      return {
        :status => 'ok',
        :code => 200,
        :friends => friends
      }.to_json

    end

    post '/api/request_beta/:email' do
      email = params[:email]

      content_type :json

      if email.blank?
        return {
          :status => 'error',
          :code => 404,
          :msg => 'email required'
        }.to_json
      end

      if !Util::valid_email?(email)
        return {
          :status => 'error',
          :code => 400,
          :msg => 'email not valid'
        }.to_json
      end


    end

    ### calendar page ###
    get '/:username' do
      @user = User.where(:username => params[:username].downcase).first
      @friends = []
      @friend = nil

      if !@user.blank?
        @friends = UserFollow.left_join(:users, :id => :user_id).where(:user_follows__user_id => @user.id).all
        @friend = UserFollow.where(:user_id => @current_user.id, :friend_id =>@user.id).first
      end

      return "error" if @user.blank?
      render "user_calendar", :layout => "calendar"
    end


  end

end
