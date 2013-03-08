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
        alloc.initWithEntity(entity_description, insertIntoManagedObjectContext:_context).tap do |model|
          model.instance_variable_set('@new_record', true)
          attributes.each do |keyPath, value|
            model.setValue(value, forKey:keyPath)
          end
        end
        yield self if block_given?
        self
      end

    end

    def destroy

      if context = managedObjectContext
        context.deleteObject(self)
        error = Pointer.new(:object)
        context.save(error)
      end

      @destroyed = true
      freeze
    end

    def destroyed?
      @destroyed || false
    end

    def new_record?
      @new_record || false
    end

    def persisted?
      !(new_record? || destroyed?)
    end

    def save
      begin
        save!
      rescue Nitron::RecordNotSaved
        return false
      end
      true
    end

    def save!
      context.insertObject(self) if new_record?

      error = Pointer.new(:object)
      unless context.save(error)
        context.deleteObject(self)
        raise Nitron::RecordNotSaved, self and return false
      end
      true
    end

  end
end