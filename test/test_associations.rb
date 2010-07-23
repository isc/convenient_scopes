require 'helper'

class TestAssociations < Test::Unit::TestCase
  
  context "Given two users" do
    setup do
      @bob = User.create :comments => [(Comment.new :body => 'Yo')]
      @slim = User.create :comments => [(Comment.new :body => 'Bye'), (Comment.new :body => 'Hello')]
    end
    
    should "has_many association" do
      assert_equal [@bob], User.comments_body_is('Yo')
    end
    
  end
  
end