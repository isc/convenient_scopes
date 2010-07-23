require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'active_record'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'convenient_scopes'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
class User < ActiveRecord::Base
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
    t.integer :age
    t.datetime :activated_at
    t.boolean :admin
  end
end
