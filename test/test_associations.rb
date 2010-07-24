require 'helper'

class TestAssociations < Test::Unit::TestCase
  
  context "convenient_scopes" do
    setup do
      @manager_group = Group.create :name => 'Managers'
      @bob = User.create :comments => [(Comment.new :body => 'Yo', :published => false, :created_at => 1.week.ago)], :group => @manager_group
      @dev_group = Group.create :name => 'Developers'
      @slim = User.create :comments => [(Comment.new :body => 'Bye', :published => false, :created_at => 10.minutes.ago),
        (Comment.new :body => 'Hello', :published => true, :created_at => 2.days.ago)],
        :group => @dev_group
    end

    should "not catch everything" do
      assert_raise NoMethodError do
        User.comment_body_is('Yo')
      end
      assert_raise NoMethodError do
        User.comments_synopsis_eq('Yo')
      end
    end
    
    should "handle has_many association + attribute conditions" do
      assert_equal [@bob], User.comments_body_equals('Yo')
      assert_equal [@slim], User.comments_body_starts_with('He')
      assert_equal [@bob], User.comments_id_is(@bob.comments.first.id)
      assert_equal [@slim], User.comments_id_is(@slim.comments.last.id)
      assert_equal [@bob], User.comments_created_at_before(3.days.ago)
    end
    
    should "handle has many association + boolean column" do
      assert_equal [@slim], User.comments_published
    end
    
    should "handle belongs_to association" do
      assert_equal [@bob], User.group_name_is('Managers')
      assert_equal [@slim], User.group_name_matches('velo')
    end
    
    should "handle two levels of association" do
      assert_equal [@dev_group], Group.users_comments_published
    end
    
    should "be able to leverage a named scope on an association" do
      Comment.scope :recent, Comment.created_at_after(1.hour.ago).created_at_not_nil
      assert_equal [@slim], User.comments_recent
      assert_equal [@dev_group], Group.users_comments_recent
    end
    
  end
  
end