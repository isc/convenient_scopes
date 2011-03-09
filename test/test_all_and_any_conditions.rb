require 'helper'

class TestAllAndAnyConditions < Test::Unit::TestCase
  
  context "convenient_scopes" do
    
    setup do
      @bob = User.create :pseudo => 'Bob Larchi'
      @slim = User.create :pseudo => 'Slim Babine'
    end
    
    should "handle conditions scopes suffixed by any" do
      # assert_equal [@bob, @slim], User.pseudo_like_any('Bob', 'Slim')
    end
    
  end
  
end