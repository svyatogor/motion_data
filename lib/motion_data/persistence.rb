module MotionData
  module Persistence

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def create(attributes={}, &block)
        begin
          model = create!(attributes, &block)
        rescue Nitron::RecordNotSaved
          return false
        end
        model
      end

      def create!(attributes={}, &block)
        model = new(attributes, &block)
        model.save!
        model
      end

      def new(attributes={}, _context = nil)
        _context ||= context
        instance = nil
        context.performBlockAndWait(lambda do
          instance = alloc.initWithEntity(entity_description, insertIntoManagedObjectContext: _context).tap do |model|
            model.instance_variable_set('@new_record', true)
            attributes.each do |keyPath, value|
              model.send("#{keyPath}=", value)
            end
          end
        end)
        yield instance if block_given?
        instance
      end

    end

    def destroy

      if context = managedObjectContext
        context.performBlockAndWait -> () {
          context.deleteObject(self)
          error = Pointer.new(:object)
          context.save(error)
        }
      end

      @destroyed = true
      freeze
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
      save_status = false
      context.performBlockAndWait -> () { save_status = context.save(error) }
      if save_status
        @new_record = false
        true
      else
        NSLog("Error on saving: %@", error.value)
        false
      end
    end

    def save!
      #if new_record?
      #  context.performBlockAndWait -> () { context.insertObject(self) }
      #end

      error       = Pointer.new(:object)
      save_status = false
      context.performBlockAndWait -> () { save_status = context.save(error) }
      if save_status
        @new_record = false
      else
        #context.performBlockAndWait -> () { context.deleteObject(self) }
        #puts error.to_object.error
        raise StandardError, error.value and return false
      end
      true
    end

    def awakeFromFetch
      @new_record = false
    end

  end
end