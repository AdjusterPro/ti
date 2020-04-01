require 'open-uri'
require 'net/http'
require 'json'

class TI
    def initialize(api_key, logger, options = {})
        @api_key = api_key
        @logger =  logger

        @subdomain = options[:subdomain] || 'adjuster'
        @debug = options[:debug] || false
    end

    def debug(msg)
      @logger.debug(msg) if @debug
    end

    def get(url)
        cursor = nil
        api_obj = url.split('/')[1]
        objects = []
        loop do
            path = url
            sep = '?'
            /\?/.match(path) { |m| sep = '&' }

            path += "#{sep}cursor=#{cursor}" unless cursor.nil?
            page = self._get path
            if page.has_key?(api_obj)
                objects += page[api_obj]
                self.debug("page had #{page[api_obj].size} objects")
            else
                objects << page
                self.debug("page had #{objects.size} objects")
            end
            break unless page.has_key?('pageInfo') and page['pageInfo']['hasMore']
            cursor = page['pageInfo']['cursor']
        end

        objects
    end

    def put(path, payload)
        self.api_request(path) do |uri, headers|
            headers['Content-Type'] = 'application/json'
            req = Net::HTTP::Put.new(uri, headers)
            req.body = payload.to_json

            req.tap { |r| self.debug("PUT request: #{r.inspect}") }
        end
    end

    def _get(path)
      self.api_request(path) do |uri, headers|
        Net::HTTP::Get.new(uri, headers)
      end
    end

    def api_request(path)
        url = "https://#{@subdomain}.thoughtindustries.com/incoming/v2/#{path}"
        headers = { 'Authorization' => "Bearer #{@api_key}" }

        uri = URI(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = yield(uri, headers)

        self.debug("requesting #{url}")
        begin
            r = http.request(req)
            self.debug("limit stats: #{_limit(r).to_json}")
            r.value || JSON.parse(r.read_body)
        rescue Net::HTTPServerException => e
            raise e unless /429/.match(e.message)

            limit = _limit(e.response)
            @logger.warn("TI#api_request received a 429, waiting #{limit[:retry_after] || 30} seconds to retry. Limit stats: #{limit.to_json}")

            sleep (limit[:retry_after] || '30').to_i
            retry
        end
    end

    def _limit(response)
      now = Time.now.to_i
      {
        :limit => response['X-RateLimit-Limit'],
        :remaining => response['X-RateLimit-Remaining'],
        :reset => response['X-RateLimit-Reset'],
        :retry_after => response['retry-after'],
        :now => now,
        :true_retry_after => response['X-RateLimit-Reset'].to_i - now
      }
    end 

    
end
