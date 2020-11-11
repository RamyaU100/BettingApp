require 'sinatra'
require 'dm-core'
require 'dm-migrations'

enable 'sessions'
DataMapper.setup(:default,ENV['DATABASE_URL']||"sqlite3://#{Dir.pwd}/gambling.db")

class Bet
    include DataMapper::Resource
    property :User_id, Serial
    property :User_name, String
    property :Password, String
    property :Win, Integer
    property :Lost, Integer
end
DataMapper.auto_migrate!
DataMapper.finalize

configure do
    enable :sessions
end


configure :development do
	DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/gambling.db")
end

configure :development, :test do
	DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/gambling.db")
end

configure :production do
	DataMapper.setup(:default, ENV['DATABASE_URL'])
end

get '/' do
    erb :login
end

get '/login' do
    if session[:user]
        erb :home
    else
        erb :login
    end
end

post '/login' do
    Bet.first_or_create({:User_name =>"ramya", :Password =>"1234567"})
    id = Bet.first(:User_name =>params[:id])
    if id!=nil && id.Password== params[:password]
        session[:win]= 0
        session[:lost]= 0
        session[:password]= params[:password]
        session[:user]= params[:id]
        session[:total_win]= id.Win
        session[:total_lost]= id.Lost
        session[:id]=id.User_id
        erb :home
    else
        erb :login
    end
end

post '/bet' do
    stake = params[:stake].to_i
    number = params[:number].to_i
    roll = rand(6) + 1
    if number == roll
      session[:win] += (stake*10)
      erb :home
    else
       session[:lost] += stake
        erb :home
    end
end

get '/logout' do
    session[:user] = nil
    session[:password] = nil
    id = Bet.get(session[:id])
    session[:total_win]+= session[:win]
    session[:total_lost]+= session[:lost]
    id.update(:Win=>session[:total_win],:Lost=>session[:total_lost])
    erb :login
    redirect '/login'
end