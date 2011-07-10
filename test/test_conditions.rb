require 'helper'

class TestConditions < Test::Unit::TestCase
  context "Given two users" do
    setup do
      @bob = User.create :pseudo => 'Bob', :first_name => 'Robert', :age => 37,
        :activated_at => 37.hours.ago, :admin => true
      @slim = User.create :pseudo => 'Slim', :first_name => 'Angelo', :age => 12,
        :activated_at => nil, :admin => false
    end

    should "equals scope" do
      assert_raises NoMethodError do
        User.blabla_eq('Bob')
      end
      assert_equal [@bob], User.pseudo_eq('Bob')
      assert_equal [@slim], User.pseudo_eq('Slim')
      assert_equal [@slim], User.pseudo_is('Slim')
      assert_equal [@bob], User.first_name_is('Robert')
    end

    should "equals scope on a relation" do
      assert_equal [@bob], User.order('age').pseudo_eq('Bob')
    end

    should "not equals scope" do
      assert_equal [@bob], User.pseudo_is_not('Slim')
      assert_equal [@bob], User.first_name_does_not_equal('Angelo')
    end

    should "less than (or equal)? scope" do
      assert_equal [@slim], User.age_lt(37)
      assert_equal [@slim], User.age_less_than_or_equal(12)
    end

    should "greater than (or equal)? scope" do
      assert_equal [@bob], User.age_greater_than(12)
      assert_equal [@bob], User.age_gte(37)
      assert_equal [@bob], User.activated_at_after(40.hours.ago)
    end

    should "like scope" do
      assert_equal [@slim], User.first_name_matches('nge')
    end

    should "not like scope" do
      assert_equal [@slim], User.pseudo_not_like('o')
    end

    should "begins / ends with scope" do
      assert_equal [@bob], User.first_name_starts_with('Rob')
      assert_equal [@slim], User.first_name_ends_with('o')
    end

    should "not begins / ends with scope" do
      assert_equal [@slim], User.first_name_does_not_start_with('Rob')
      assert_equal [@bob], User.first_name_doesnt_end_with('o')
    end

    should "(not)? null scope" do
      assert_equal [@slim], User.activated_at_null
      assert_equal [@bob], User.activated_at_not_nil
    end

    should "boolean columns" do
      assert_equal [@bob], User.admin
      assert_equal [@slim], User.not_admin
      assert_raises NoMethodError do
        User.not_age
      end
      assert_raises NoMethodError do
        User.not_shablagoo
      end
    end

    should "not mix up scopes" do
      User.age_gt(0).pseudo_null
      sql = User.pseudo_null.to_sql
      assert_nil sql['age']
    end

    should "between" do
      assert_equal [@bob], User.activated_at_between(40.hours.ago, 34.hours.ago)
      assert_equal [], User.activated_at_between(40.hours.ago, 38.hours.ago)
    end

  end
end
