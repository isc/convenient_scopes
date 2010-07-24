require 'helper'

class TestAssociations < Test::Unit::TestCase
  
  context "Given two users" do
    setup do
      @bob = User.create :comments => [(Comment.new :body => 'Yo', :published => false, :created_at => 1.week.ago)]
      @slim = User.create :comments => [(Comment.new :body => 'Bye', :published => false), (Comment.new :body => 'Hello', :published => true)]
    end
    
    should "has_many association" do
      assert_equal [@bob], User.comments_body_is('Yo')
      assert_equal [@slim], User.comments_body_starts_with('He')
      assert_equal [@bob], User.comments_id_is(@bob.comments.first.id)
      assert_equal [@slim], User.comments_id_is(@slim.comments.last.id)
      assert_equal [@slim], User.comments_published
      assert_equal [@bob], User.comments_created_at_before(1.week.ago)
    end
    
  end
  
end