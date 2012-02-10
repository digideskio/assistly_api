module Assistly
  module API
    module Client

      BASE_PATH = "/api/v1"
      DEFAULT_FORMAT = :json
      HTTP_VERBS = [:get, :post, :put, :delete, :head]

      @@debug_mode = false

      def debug_mode=(debug)
        @@debug_mode = debug
      end

      def debug_mode
        @@debug_mode
      end

      def authentication=(authentication)
        @@authentication = authentication
      end

      def authentication
        @@authentication
      end

      def client
        @@client ||= @@authentication.access_token
      end

      def find(options = {})
        get(options)
      end
      
      alias_method :all, :find

      def find_each(options = {}, paging_options = {})

        per_page     = paging_options[:count]      || 100
        current_page = paging_options[:start_page] || 1
        sleep_after  = paging_options[:sleep]      || nil

        begin
          puts "Requesting page #{current_page} of #{per_page} #{resource_singular} records..." if debug_mode
          result = find(options.merge(:page => current_page, :count => per_page))
          puts "Number of records: #{result.total}. Pages: #{result.total_pages}" if debug_mode && current_page == 1
        
          result.each { |r| yield(r) }
          sleep(sleep_after) if sleep_after
          current_page += 1
        end while result.more?
      end

      private

      def get(options = {})
        request(:get, options)
      end

      def post(options = {})
        request(:post, options)
      end
      
      def put(options = {})
        request(:put, options)
      end

      def resource_path
        "#{BASE_PATH}/#{resource_plural}"
      end

      def resource_singular
        self.name.split('::').last.downcase
      end

      def resource_plural
        "#{resource_singular}s"
      end

      def build_path(options, format_extension = true)
        options = options.dup
        path = resource_path
        path << "/#{options.delete(:id)}" if options[:id]
        path << options.delete(:nested_resource) if options[:nested_resource]
        path << ".#{DEFAULT_FORMAT}" if format_extension
        path << "?#{build_params(options)}" unless options.empty?
        path
      end

      def build_params(params)
        params.map{|key, value| "#{CGI.escape(key.to_s)}=#{encode_param(value)}"}.join('&')
      end

      def encode_param(value)
        case value
          when DateTime, Date, Time; value.strftime('%s')
          when Integer;  value.to_s
          else CGI.escape(value.to_s)
        end
      end

      def request(verb, options = {})
        raise ArgumentError, "must be one of #{HTTP_VERBS.join(',')}" unless HTTP_VERBS.include?(verb.to_sym)
        path = build_path(options)
        puts "Sending #{verb} request to #{path}..." if debug_mode
        response = client.send(verb, path)
        case response
        when Net::HTTPSuccess
          # puts response.body.to_s if debug_mode
          hash = parse(response)
          if hash['results']
            Result.new(hash, self)
          else
            self.new(hash)
          end
        when Net::HTTPUnauthorized
          raise "Unauthorized! Please check your credentials"
        when Net::HTTPClientError
          raise "Client error (#{response.code}): #{response.body}"
        when Net::HTTPServerError
          raise "Server error (#{response.code}): #{response.body}"
        else
          raise "Unknown response: #{response.inspect}"
        end
      end

      def parse(response, format = DEFAULT_FORMAT)
        case format.to_sym
        when :json
          hash = JSON.parse(response.body)
          raise "Expected JSON hash but got #{response.body.to_s.inspect}!" unless hash.kind_of?(Hash)
          return hash
        else
          response.body
        end
      end
    end
  end
end