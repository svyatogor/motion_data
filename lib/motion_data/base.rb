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
      @context ||= self.class.context
    end

    class << self
      def context
        @context ||= UIApplication.sharedApplication.delegate.managedObjectContext
      end

      def serialize(*args)
        options = args.last.is_a?(::Hash) ? args.pop : {}

        if args.length > 1
          args.each {|name| serialize name, options}
        else
          name = args.first

          define_method name do
            willAccessValueForKey name
            v = Marshal.load(self.send(:"primitive#{name.capitalize}").nsstring)
            didAccessValueForKey name
            v
          end

          define_method "#{name}=" do |v|
            willChangeValueForKey name
            self.send(:"primitive#{name.capitalize}=", Marshal.dump(v).nsdata)
            didChangeValueForKey name
            v
          end
        end

      end

      def entity_description
        @_metadata ||= UIApplication.sharedApplication.delegate.managedObjectModel.entitiesByName[name]
      end
    end
  end
end