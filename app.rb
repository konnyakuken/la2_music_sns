require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models'
require 'dotenv/load'

require "sinatra/activerecord"#activerecordを使えるように

enable :sessions

helpers do#erbファイル上で利用できるメソッド
    def current_user
       User.find_by(id: session[:user]) #ログイン中のユーザー情報取得
    end
end



get '/' do
    erb :index
end

get"/signup" do
    erb:sign_up
end

post "/signup" do
    user=User.create(
        name: params[:name],
        password: params[:password],
        password_confirmation: params[:password_confirmation],
        icon: params[:file]
    )
    if user.persisted? #Active Record object がDB に保存済みかどうかを判定
        session[:user] = user.id
    end
    #p params[:name],params[:password],session[:user]
    redirect"/"
end

post "/signin" do
    user=User.find_by(name: params[:name])
    if user && user.authenticate(params[:password])
       session[:user]=user.id 
    end
    #p session[:name]
    redirect "/"
end

get "/signout" do#ログアウト
   session[:user]=nil
   redirect"/"
end
