require 'digest'

class TiTest < Test::Unit::TestCase
    def ti
        @ti ||= TI.new(env(:TI), Logger.new(STDERR), :debug => true, :subdomain => env(:TI_TEST_SUBDOMAIN))
    end

    def env(var_sym)
      ENV[var_sym.to_s] || raise("please define #{var_sym.to_s} in env")
    end

    def test_429_handling
#     omit
      21.times { self.ti.get("users/#{env(:TI_TEST_USER)}") }
    end

    def test_read_profile_field
#     omit
      test_user = self.ti.get("users/#{env(:TI_TEST_USER)}")[0]
      assert_equal(env(:TI_TEST_USER_EMAIL), test_user['email'])
    end

		def test_write_profile_field
#     omit
      test_user = self.ti.get("users/#{env(:TI_TEST_USER)}")[0]
      ref_user = test_user.dup
      new_value = Digest::MD5.hexdigest(test_user['ref10'] || '')
      ref_user['ref10'] = new_value

      test_user = self.ti.put("users/#{env(:TI_TEST_USER)}", { 'email' => test_user['email'], 'ref10' => new_value })
      ref_user.keys.reject {|k| k=='lastActiveAt' }
      .each { |k| assert_equal("#{k} = #{ref_user[k]}", "#{k} = #{test_user[k]}") }
    end
		  
end
