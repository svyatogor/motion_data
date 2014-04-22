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
      managedObjectContext
    end

    def in_context(_context)
      if _context.is_a? Symbol
        _context = case _context
                     when :private
                       App.delegate.background_moc
                     else
                       App.delegate.moc
                   end
      end

      if _context != managedObjectContext
        if new_record?
          raise "You cannot change context on new record."
        else
          obj_in_context = nil

          NSLog "Do NOT access private MOC (#{_context.concurrencyType}) on #{Dispatch::Queue.current}" if (Dispatch::Queue.main.to_s == Dispatch::Queue.current.to_s && _context.concurrencyType == NSPrivateQueueConcurrencyType)
          NSLog "Do NOT access main MOC on private queue" if (Dispatch::Queue.main.to_s != Dispatch::Queue.current.to_s && _context.concurrencyType == NSMainQueueConcurrencyType)
          _context.performBlockAndWait -> { obj_in_context = _context.objectWithID objectID }
          obj_in_context
        end
      else

        self
      end
    end

    def _id
      objectID.URIRepresentation.absoluteString
    end

    class << self
      def serialize(*args)
        options = args.last.is_a?(::Hash) ? args.pop : {}

        if args.length > 1
          args.each { |name| serialize name, options }
        else
          name = args.first

          define_method name do
            willAccessValueForKey name
            v = self.send(:"raw_#{name}")
            didAccessValueForKey name
            begin
              BW::JSON.parse(v.to_s)
            rescue
              nil
            end
          end

          define_method "#{name}=" do |v|
            willChangeValueForKey name
            self.send(:"raw_#{name}=", BW::JSON.generate(v))
            didChangeValueForKey name
            v
          end
        end

      end

      def entity_description
        @_metadata ||= App.delegate.managedObjectModel.entitiesByName[name]
      end
    end
  end
end