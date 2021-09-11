require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models'
require 'dotenv/load'

require "sinatra/activerecord"#activerecordを使えるように

require "open-uri"
require "json"
require "net/http"

enable :sessions

helpers do#erbファイル上で利用できるメソッド
    def current_user
       User.find_by(id: session[:user]) #ログイン中のユーザー情報取得
    end
    

end

before do
   Dotenv.load
   Cloudinary.config do |config|
       config.cloud_name = ENV["CLOUD_NAME"]
       config.api_key = ENV["CLOUDINARY_API_KEY"]
       config.api_secret = ENV["CLOUDINARY_API_SECRET"]
    end
end

get '/' do
   @musics=Post.all
    erb :index
end

get"/signup" do
    erb:sign_up
end

post "/signup" do
    img_url=""
    if params[:file]
       img =params[:file]
       tempfile =img[:tempfile]
       upload= Cloudinary::Uploader.upload(tempfile.path)#Cloudinaryに画像をアップロード
       img_url=upload["url"]
    end
    
    user=User.create(
        name: params[:name],
        password: params[:password],
        password_confirmation: params[:password_confirmation],
        icon: img_url
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
    #p session[:user]
    redirect "/"
end

get "/signout" do#ログアウト
   session[:user]=nil
   redirect"/"
end

get "/home"do
    @musics=Post.where(user_id: session[:user])
   erb :home 
end

get"/search"do
    keyword=params[:keyword]
    uri=URI("https://itunes.apple.com/search")
   uri.query=URI.encode_www_form({ term: keyword, country: "JP",media: "music",limit: 10})
   res=Net::HTTP.get_response(uri)
   returned_JSON=JSON.parse(res.body)
   
   @musics= returned_JSON["results"]
    
   erb :search
end

post "/search"do
    keyword=params[:keyword]
    uri=URI("https://itunes.apple.com/search")
    uri.query=URI.encode_www_form({ term: keyword, country: "JP",media: "music",limit: 10})
    res=Net::HTTP.get_response(uri)
    returned_JSON=JSON.parse(res.body)
   
   @musics= returned_JSON["results"]
   

   erb :search
end



post "/new"do
    
    Post.create(
        jacket: params[:artwork],
        artist: params[:artistName],
        song: params[:trackName],
        album: params[:collectionName],
        sample: params[:previewUrl],
        comment: params[:comment],
        user_id: session[:user]
    )
    redirect"/"
end

=begin
post "/delete/:id"do
    #song=Post.where(song: params[:song]).where(song: params[:id])
    song=Post.find(params[:id])
    song.destroy
    redirect "/home"
end
=end

get "/delete/:id"do
    #song=Post.where(song: params[:song]).where(song: params[:id])
    song=Post.find(params[:id])
    song.destroy
    redirect "/home"
end

get "/edit/:id"do
    @song=Post.find(params[:id])
    erb :edit
end

post "/edit/:id"do
    song=Post.find(params[:id])
    song.comment=params[:edit]
    song.save
    redirect"/home"
end