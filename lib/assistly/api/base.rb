module Assistly
  module API
    
    class Base < OpenStruct
      extend Client
      
      def initialize(hash)
        class_name = self.class.name.split('::').last.downcase
        super(hash[class_name])
      end

      def to_hash
        @table.dup
      end
      
      def id
        @table[:id]
      end
    end
  end
end