require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'active_record'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'convenient_scopes'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
class User < ActiveRecord::Base
  has_many :comments
  belongs_to :group
end
class Group < ActiveRecord::Base
  has_many :users
end
class Comment < ActiveRecord::Base
  belongs_to :user
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
    t.timestamps
  end
  create_table :groups do |t|
    t.string :name
    t.timestamps
  end
  create_table :comments do |t|
    t.string :body
    t.integer :user_id
    t.boolean :published
    t.timestamps
  end
end
