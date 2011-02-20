require 'helper'

class TestOrdering < Test::Unit::TestCase

  context "convenient_scopes" do

    setup do
      @bob = User.create :age => 43, :pseudo => 'Bob'
      @slim = User.create :age => 27, :pseudo => 'Slim'
      @avon = User.create :age => 37, :pseudo => 'Avon'
      @managers = Group.create :users => [@bob, @avon]
      @developers = Group.create :users => [@slim]
    end
    
    should "allow ordering by attributes" do
      assert_equal [@slim, @avon, @bob], User.ascend_by_age
      assert_equal [@bob, @avon, @slim], User.descend_by_age
    end

    should "allow ordering by attributes of an association" do
      assert_equal [@developers, @managers], Group.ascend_by_users_age.uniq
      assert_equal [@managers, @developers], Group.descend_by_users_age.uniq
    end

    should "not screw stuff" do
      User.where(:pseudo => 'Bob').descend_by_pseudo
      sql = User.descend_by_pseudo.to_sql
      assert_nil sql['Bob']
      sql = User.where(:pseudo => 'Slim').descend_by_pseudo.to_sql
      assert sql['Slim']
    end

  end

end
