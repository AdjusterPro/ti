require 'open-uri'
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
            page = JSON.parse(self.api_get path)
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

    def api_request(path)
        url = "https://#{@subdomain}.thoughtindustries.com/incoming/v2/#{path}"
        headers = { 'Authorization' => "Bearer #{@api_key}" }
        self.debug("requesting #{url}")
        begin
            yield(url, headers)
        rescue Exception => e
            raise e unless /429/.match(e.message)

            retry_after = e.io.meta['retry-after']
            @logger.warn("TI#api_get received a 429, waiting #{retry_after} seconds (or 30) to retry")

            sleep (retry_after || '30').to_i
            retry
        end
    end

    def api_get(path)
        self.api_request(path) do |url, headers|
          output = ''
          open(url, headers) { |f| f.each_line { |line| output += line } }
          output
        end
    end
end
