module MotionData
  module Persistence

    def self.included(base)
      base.extend(ClassMethods)
    end

    def ensure_correct_queue
      raise "Do NOT access private MOC on main queue" if (Dispatch::Queue.main.to_s == Dispatch::Queue.current.to_s && context.concurrencyType == NSPrivateQueueConcurrencyType)
      raise "Do NOT access main MOC on private queue" if (Dispatch::Queue.main.to_s != Dispatch::Queue.current.to_s && context.concurrencyType == NSMainQueueConcurrencyType)
    end

    module ClassMethods
      def ensure_correct_queue(context)
        raise "Do NOT access private MOC on main queue" if (Dispatch::Queue.main.to_s == Dispatch::Queue.current.to_s && context.concurrencyType == NSPrivateQueueConcurrencyType)
        raise "Do NOT access main MOC on private queue" if (Dispatch::Queue.main.to_s != Dispatch::Queue.current.to_s && context.concurrencyType == NSMainQueueConcurrencyType)
      end

      def create(*args)
        model = new(*args)
        model.save
        model
      end

      def create!(*args)
        model = new(*args)
        model.save!
        model
      end

      def new(*args)
        attributes = {}
        context    = nil

        if args.length == 1 and args[0].is_a? Symbol
          context = args[0]
        end

        if args.length == 1 and args[0].is_a? Hash
          attributes = args[0]
        end

        if args.length == 2
          attributes = args[0]
          context    = args[1]
        end

        if context.is_a? Symbol
          context = case context
                      when :private
                        App.delegate.background_moc
                      else
                        App.delegate.moc
                    end
        end

        context  ||= App.delegate.moc
        ensure_correct_queue(context)

        instance = alloc.initWithEntity(entity_description, insertIntoManagedObjectContext: context).tap do |model|
          model.instance_variable_set('@new_record', true)
          attributes.each do |keyPath, value|
            value = value.in_context(context) if value.is_a?(NSManagedObject)
            model.send("#{keyPath}=", value)
          end
        end
        yield instance if block_given?
        instance
      end

    end

    def delete(options = {})
      #e = Pointer.new(:object)
      #unless validateForDelete(e)
      #  log "Object of type #{self.class.name} cannot be deleted at this time: %@", e.value
      #end
      before_delete if respond_to?(:before_delete)
      ensure_correct_queue
      managedObjectContext.deleteObject(self)
      after_delete if respond_to?(:after_delete)

      @destroyed = true
      options[:save] ? save : managedObjectContext.processPendingChanges
      freeze
    end

    def destroy
      delete save: true
    end

    def destroyed?
      @destroyed || false
    end

    def new_record?
      @new_record
    end

    def persisted?
      !(new_record? || destroyed?)
    end

    def save
      error       = Pointer.new(:object)
      save_status = context.save(error)
      unless save_status
        log("Error on saving: #{error.value.description}") if error.value
      end
      save_status
    end

    def save!
      save
    end

    def awakeFromFetch
      @new_record = false unless @destroyed
    end

    def didSave
      @new_record = false unless @destroyed
    end

  end
end