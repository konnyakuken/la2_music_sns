require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection

class User<ActiveRecord::Base
    has_many :likes;
    has_many :like_posts, :through => :likes,:source => :post;
    has_many :posts;
    
    has_secure_password
    #validates :password,
    #    format: {with:/(?=.*?[a-z])(?=.*?[0-9])/},
    #    length: {in: 5..10}
end

class Post<ActiveRecord::Base
    has_many :likes;
    has_many :like_users, :through => :likes, :source =>:user;
    belongs_to :user;
end


class Like<ActiveRecord::Base
    belongs_to :post;
    belongs_to :user;
end