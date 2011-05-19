module Assistly
  module API
    
    class Result
      include Enumerable
      attr_reader :results, :total, :count, :page
      
      def initialize(hash, klass)
        @total = hash['total'].to_i
        @count = hash['count'].to_i
        @page  = hash['page'].to_i
        return unless hash['results']
        
        @results = hash['results'].collect do |resource|
          klass.new(resource)
        end
        super(@results)
      end
      
      def each(&blk)
        @results.each(&blk)
      end
      
      alias_method :size, :count
      alias_method :length, :count
      
      def total_pages(per_page = nil)
        per_page ||= count
        (total.to_f / per_page.to_f).ceil
      end
      
      def more?(per_page = nil)
        total_pages(per_page) > page
      end
    end
  end
end
