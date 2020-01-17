class TI
    def initialize(subdomain = 'adjuster')
        raise 'please define TI in environment (s/b an API key)' if ENV['TI'].nil?
        @subdomain = subdomain
        @cache = {}
    end

    def get_all(url)
        cursor = nil
        api_obj = url.split('/')[1]
        objects = []
        loop do
            path = url
            sep = '?'
            /\?/.match(path) { |m| sep = '&' }

            path += "#{sep}cursor=#{cursor}" unless cursor.nil?
            page = JSON.parse(self.get path)
            if page.has_key?(api_obj)
                objects += page[api_obj]
                log('debug', "page had #{page[api_obj].size} objects")
            else
                objects << page
                log('debug', "page had #{objects.size} objects")
            end
            break unless page.has_key?('pageInfo') and page['pageInfo']['hasMore']
            cursor = page['pageInfo']['cursor']
        end

        objects
    end

    def get(url)
        @cache[url] ||= api_get(url)
    end

    def api_get(url)
        full_url = "https://#{@subdomain}.thoughtindustries.com/incoming/v2#{url}"
        log('debug', "fetching #{full_url}")
        output = ''
        loop do
            begin
                open(full_url, { 'Authorization' => "Bearer #{ENV['TI']}" }) do |f|
                    f.each_line { |line| output += line }
                end
                break
            rescue Exception => e
                raise e unless /429/.match(e.message)
                log('warning', 'got 429, waiting half a minute for TI')
                sleep 30
                next
            end
        end
        output
    end
end
