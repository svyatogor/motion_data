module MotionData
  module Migrations
    module Entity
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def entity_name
          name.split("::").last
        end
      end
    end
  end
end
