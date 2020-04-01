require 'digest'

class TiTest < Test::Unit::TestCase
    def ti
        @ti ||= TI.new(ENV['TI'] || raise("please define TI in env (s/b API key)"), Logger.new(STDOUT), :debug => true)
    end

    def test_429_handling
      20.times { self.ti.get("users/26dd1069-db08-4ee4-8575-e4693218cdd1") }
    end

    def test_read_profile_field
      test_user = self.ti.get('users/26dd1069-db08-4ee4-8575-e4693218cdd1')[0]
      assert_equal('bdunlap@agentintellect.com', test_user['email'])
    end

		def test_write_profile_field
      test_user = self.ti.get('users/26dd1069-db08-4ee4-8575-e4693218cdd1')[0]
      ref_user = test_user.dup
      new_value = Digest::MD5.hexdigest(test_user['ref10'] || '')
      ref_user['ref10'] = new_value

      test_user = self.ti.put('users/26dd1069-db08-4ee4-8575-e4693218cdd1', { 'email' => test_user['email'], 'ref10' => new_value })
      ref_user.keys.reject {|k| k=='lastActiveAt' }
      .each { |k| assert_equal("#{k} = #{ref_user[k]}", "#{k} = #{test_user[k]}") }
    end
		  
end
