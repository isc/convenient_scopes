require 'rubygems'
require 'bundler'
require 'logger'
Bundler.require

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'convenient_scopes'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
class User < ActiveRecord::Base
  has_many :comments
  belongs_to :group
  belongs_to :user_profile
end
class Group < ActiveRecord::Base
  has_many :users
end
class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
end
class UserProfile < ActiveRecord::Base
  has_one :user
end
class Post < ActiveRecord::Base
  has_many :comments
end

class Test::Unit::TestCase
  def teardown
    User.delete_all
  end
end

ActiveRecord::Base.configurations = true
ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define(:version => 1) do
  create_table :users do |t|
    t.string :pseudo, :first_name, :last_name
    t.integer :group_id, :age
    t.datetime :activated_at
    t.boolean :admin
    t.integer :user_profile_id
    t.timestamps
  end
  create_table :groups do |t|
    t.string :name
    t.timestamps
  end
  create_table :comments do |t|
    t.string :body
    t.integer :user_id, :post_id
    t.boolean :published
    t.timestamps
  end
  create_table :user_profiles do |t|
    t.date :birthdate
    t.string :email
  end
  create_table :posts do |t|
    t.string :title, :author
    t.text :body
  end
end
