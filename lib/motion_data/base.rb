module MotionData
  class Base < NSManagedObject
    include MotionData::FinderMethods
    include MotionData::Persistence
    include MotionData::Validations

    def inspect
      properties = []
      entity.properties.select { |p| p.is_a?(NSAttributeDescription) }.each do |property|
        properties << "#{property.name}: #{valueForKey(property.name).inspect}"
      end

      "#<#{entity.name} #{properties.join(", ")}>"
    end

    def context
      @context ||= (managedObjectContext || self.class.context)
    end

    class << self
      def context
        @context ||= UIApplication.sharedApplication.delegate.managedObjectContext
      end

      def property(name, type, options={})
      end

      def has_many(name, options={})
      end

      def belongs_to(name, options={})
      end

      def entity_description
        @_metadata ||= UIApplication.sharedApplication.delegate.managedObjectModel.entitiesByName[name]
      end
    end
  end
end