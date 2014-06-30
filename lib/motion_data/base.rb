module MotionData
  OBJ_CACHE      = {}
  CACHED_KLASSES = []
  class Base < NSManagedObject
    include MotionData::FinderMethods
    include MotionData::Persistence
    include MotionData::Validations

    class << self
      def enable_caching
        CACHED_KLASSES << self.name
      end

      def core_cacheable?
        @cacheable ||= self.class.ancestors.map(&:name).any? { |k| CACHED_KLASSES.include? k }
      end
    end

    def inspect
      properties = []
      entity.properties.select { |p| p.is_a?(NSAttributeDescription) }.each do |property|
        properties << "#{property.name}: #{valueForKey(property.name).inspect}"
      end

      "#<#{entity.name} #{properties.join(", ")}>"
    end

    def core_cache
      return self unless self.class.core_cacheable?
      if OBJ_CACHE[objectID]
        OBJ_CACHE[objectID]
      else
        OBJ_CACHE[objectID] = self
      end
    end

    def schedule(*args, &block)
      if block
        App.delegate.background_moc.performBlock -> {
          obj = if self.class.core_cacheable?
                  OBJ_CACHE[objectID] ||= App.delegate.background_moc.objectWithID(objectID)
                else
                  App.delegate.background_moc.objectWithID(objectID)
                end
          args.unshift obj
          block.call *args

          error = Pointer.new(:object)
          unless App.delegate.background_moc.save(error)
            log("Error on saving: #{error.value.description}") if error.value
          end
        }
      else
        @scheduler = Scheduler.new(self)
      end
    end

    def context
      managedObjectContext
    end

    def assert_background
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

          raise "Do NOT access private MOC (#{_context.concurrencyType}) on #{Dispatch::Queue.current}" if (Dispatch::Queue.main.to_s == Dispatch::Queue.current.to_s && _context.concurrencyType == NSPrivateQueueConcurrencyType)
          raise "Do NOT access main MOC on private queue" if (Dispatch::Queue.main.to_s != Dispatch::Queue.current.to_s && _context.concurrencyType == NSMainQueueConcurrencyType)
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


  class Scheduler
    def initialize(object)
      @object = WeakRef.new(object)
    end

    def method_missing(method, *args)
      App.delegate.background_moc.performBlock -> {
        obj = App.delegate.background_moc.objectWithID(@object.objectID)
        obj.send(method, *args)
        obj.save
      }
    end
  end
end