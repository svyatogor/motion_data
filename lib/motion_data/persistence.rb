module MotionData
  module Persistence

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def create(attributes={}, &block)
        model = new(attributes, &block)
        model.save
        model
      end

      def create!(attributes={}, &block)
        model = new(attributes, &block)
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
        instance = nil
        context.performBlockAndWait(lambda do
          instance = alloc.initWithEntity(entity_description, insertIntoManagedObjectContext: context).tap do |model|
            model.instance_variable_set('@new_record', true)
            attributes.each do |keyPath, value|
              value = value.in_context(context) if value.is_a?(NSManagedObject)
              model.send("#{keyPath}=", value)
            end
          end
        end)
        yield instance if block_given?
        instance
      end

    end

    def delete(options = {})
      before_delete if respond_to?(:before_delete)
      managedObjectContext.performBlockAndWait -> () { managedObjectContext.deleteObject(self) }
      after_delete if respond_to?(:after_delete)

      @destroyed = true
      save if options[:save]
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
      App.delegate.save! managedObjectContext
    end

    def save!
      App.delegate.save! managedObjectContext
    end

    def awakeFromFetch
      @new_record = false
    end

    def didSave
      @new_record = false unless @destroyed
    end

  end
end