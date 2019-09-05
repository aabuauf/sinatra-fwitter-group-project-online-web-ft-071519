require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "password_security"
  end

  get '/' do
    erb :home
  end

  get '/signup' do
    if session[:user_id] != nil
      redirect "/tweets"
    end
    erb :"/users/signup"
  end

  
  post "/signup" do
    user = User.create(:username => params[:username], :password => params[:password], :email => params[:email])
    if user.save && params[:username] != "" && params[:password] != "" && params[:email] != ""
      session[:user_id] = user.id
        redirect "/tweets"
      else
        redirect "/signup"
    end 
  end
  
  get '/login' do
    if session[:user_id] != nil
      redirect "/tweets"
    end
    erb :"/users/login"
  end

  post "/login" do
    
    @user = User.find_by(:username => params[:username])
   
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect "/tweets"
    else
      redirect "/failure"
    end
  end

  get '/tweets' do
    if session[:user_id] != nil
      @user = User.find(session[:user_id])
      @userTweetsArray = Tweet.all
      erb :tweets
    else
      redirect "/login"
    end
  end

  get '/logout' do
    if session[:user_id] != nil
      session.clear
      redirect "/login"
    else
      redirect "/"
    end
  end

  get '/users/:slug' do
  
      @user= User.find_by_slug(params[:slug])
      @userTweetsArray = @user.tweets
      
        erb :'/tweets/show' 
  end

  get '/tweets/new' do
    if Helpers.is_logged_in?(session)
      erb :'/tweets/new'
    else
      redirect "/login"
    end
  end

  post '/tweets' do

    if Helpers.is_logged_in?(session) && params[:content]!=""
      @user = Helpers.current_user(session)
      @tweet = Tweet.create(:content => params[:content])
      @user.tweets << @tweet
      @user.save
      
    end
    redirect '/tweets/new'
  end

  get '/tweets/:id' do
    @tweet = Tweet.find_by_id(params[:id])
    if Helpers.is_logged_in?(session)
      erb :'/tweets/showTweet'
    else
      redirect "/login" 
    end
  end

  get '/tweets/:id/edit' do
    if Helpers.is_logged_in?(session)
      @tweet = Tweet.find_by_id(params[:id])
      @user = Helpers.current_user(session)
      if @user.tweets.include?(@tweet)
        erb :"/tweets/edit"
      end
    else
      redirect "/login" 
    end
  end
  patch '/tweets/:id/edit' do

    if Helpers.is_logged_in?(session)
      @tweet = Tweet.find_by_id(params[:id])
      @user = Helpers.current_user(session)
      if params.key?("edit")
        erb :"/tweets/edit"
      elsif params.key?("delete")
        if @user.tweets.include?(@tweet)
          @tweet.delete
        end
      end
    else
      redirect "/login" 
    end
    
  end

  patch '/tweets/:id' do
    @tweet = Tweet.find_by_id(params[:id])
    if params[:content] != ""
        @tweet.content = params[:content]
        @tweet.save
      
      if Helpers.is_logged_in?(session)
        erb :'/tweets/showTweet'
      else
        redirect "/login" 
      end
    else
      redirect "/tweets/#{@tweet.id}/edit"
    end
  end
end

