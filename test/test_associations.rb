require 'helper'

class TestAssociations < Test::Unit::TestCase
  
  context "Given two users" do
    setup do
      @manager_group = Group.create :name => 'Managers'
      @bob = User.create :comments => [(Comment.new :body => 'Yo', :published => false, :created_at => 1.week.ago)], :group => @manager_group
      @dev_group = Group.create :name => 'Developers'
      @slim = User.create :comments => [(Comment.new :body => 'Bye', :published => false), (Comment.new :body => 'Hello', :published => true)],
        :group => @dev_group
    end
    
    should "has_many association + attribute conditions" do
      assert_equal [@bob], User.comments_body_is('Yo')
      assert_equal [@slim], User.comments_body_starts_with('He')
      assert_equal [@bob], User.comments_id_is(@bob.comments.first.id)
      assert_equal [@slim], User.comments_id_is(@slim.comments.last.id)
      assert_equal [@bob], User.comments_created_at_before(1.week.ago)
    end
    
    should "has many association + boolean column" do
      assert_equal [@slim], User.comments_published
    end
    
    should "belongs_to association" do
      assert_equal [@bob], User.group_name_is('Managers')
      assert_equal [@slim], User.group_name_matches('velo')
    end
    
    should "two levels of association" do
      assert_equal [@dev_group], Group.users_comments_published
    end
    
  end
  
end