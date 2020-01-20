class TiTest < Test::Unit::TestCase
    def ti
        @ti ||= TI.new(ENV['TI'], Logger.new(STDOUT))
    end

    def test_429_handling
        omit # this one shouldn't really be automated; strictly for dev env

        50.times { self.ti.get("users/26dd1069-db08-4ee4-8575-e4693218cdd1") }
    end

    def test_read_profile_field
      test_user = self.ti.get('users/26dd1069-db08-4ee4-8575-e4693218cdd1')[0]
      assert_equal('bdunlap@agentintellect.com', test_user['email'])
    end
end
