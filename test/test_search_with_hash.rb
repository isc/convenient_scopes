require 'helper'

class TestSearchWithHash < Test::Unit::TestCase
  
  context "Given two users" do
    setup do
      @bob = User.create :pseudo => 'Bob', :first_name => 'Robert', :age => 37,
        :activated_at => 37.hours.ago, :admin => true
      @slim = User.create :pseudo => 'Slim', :first_name => 'Angelo', :age => 12,
        :activated_at => nil, :admin => false
    end

    should "search with hash" do
      assert_equal [@bob], User.search(:pseudo_like => 'Bo')
      assert_equal [], User.search(:pseudo_like => 'Bo', :age_is => 12)
    end
    
    should "search with hash with scopes with no argument" do
      assert_equal [@bob], User.search(:admin => true)
      assert_equal [@slim], User.search(:not_admin => true)
    end
    
    should "not apply the scope when the value associated is false" do
      assert_equal [@bob, @slim], User.search(:admin => false)
    end
    
    should "be able to leverage existing scopes" do
      User.scope :underage, User.age_lt(18)
      assert_equal [@slim], User.search(:underage => true)
    end
    
    should "be safe when using search with hash" do
      assert_raises ConvenientScopes::InvalidScopes do
        User.search :destroy => @bob.id
      end
      assert_equal 2, User.count
    end
    
    should "not mess up previous scoping" do
      assert_equal [], User.where(:age => 37).search(:first_name_is => 'Angelo')
    end
    
    should "be able to pass common ar methods in search" do
      assert_equal [@bob], User.search(:where => "age = 37")
    end
    
  end
  
end
