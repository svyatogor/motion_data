module MotionData
  class Scope < NSFetchRequest
    def initWithClass(klass)
      @klass = klass
      if init
        self.entity = klass.entity_description
      end
      self
    end

    def to_a
      error_ptr = Pointer.new(:object)

      result = context.executeFetchRequest(self, error: error_ptr)
      result
    end

    alias_method :all, :to_a

    def count
      #return to_a.count if self.fetchOffset > 0
      error_ptr = Pointer.new('@')
      context.countForFetchRequest self, error: error_ptr
    end

    def destroy_all
      to_a.map &:destroy
    end

    def except(query_part)
      case query_part.to_sym
        when :where
          self.predicate = nil
        when :order
          self.sortDescriptors = nil
        when :limit
          self.fetchLimit = 0
        else
          raise ArgumentError, "unsupported query part '#{query_part}'"
      end
      self
    end

    def first
      _fetchLimit  = self.fetchLimit
      _fetchOffset = self.fetchOffset

      self.fetchLimit = 1
      _first          = to_a[0]

      self.fetchLimit  = _fetchLimit
      self.fetchOffset = _fetchOffset
      _first
    end

    def last
      _fetchLimit  = self.fetchLimit
      _fetchOffset = self.fetchOffset

      count = countAll
      self.fetchOffset = count - 1 unless count < 1
      self.fetchLimit = 1
      _last           = to_a[0]

      self.fetchLimit  = _fetchLimit
      self.fetchOffset = _fetchOffset
      _last
    end

    def limit(l)
      raise ArgumentError, "limit '#{l}' cannot be less than zero. Use zero for no limit." if l < 0
      self.fetchLimit = l
      self
    end

    def offset(o)
      raise ArgumentError, "offset '#{o}' cannot be less than zero." if o < 0
      self.fetchOffset = o
      self
    end

    def order(column, opts={})
      descriptors = (sortDescriptors || []).clone
      descriptors << NSSortDescriptor.sortDescriptorWithKey(column.to_s, ascending: opts.fetch(:ascending, true))
      self.sortDescriptors = descriptors
      self
    end

    def pluck(column)
      self.resultType = NSDictionaryResultType

      attribute_description = entity.attributesByName[column.to_s]
      raise ArgumentError, "#{column} not a valid column name" if attribute_description.nil?

      self.propertiesToFetch = [attribute_description]
      result                 = to_a.collect { |r| r[column] }

      self.resultType = NSManagedObjectResultType
      result
    end

    def uniq
      self.clone.tap { |_self| _self.returnsDistinctResults = true }
    end

    def where(criteria, *args)
      case criteria
        when Hash
          new_predicate = NSCompoundPredicate.andPredicateWithSubpredicates(criteria.map do |keyPath, value|
            Predicate::Builder.new(keyPath) == value
          end)
        #when Scope
        #  sortDescriptors = sortDescriptorsByAddingSortDescriptors(*conditions.sortDescriptors)
        #  predicate = conditions.predicate
        when NSPredicate
          new_predicate = criteria
        when String
          new_predicate = NSPredicate.predicateWithFormat(criteria.gsub("?", "%@"), argumentArray: args)
        else
          raise ArgumentError, "unsupported where conditions class `#{criteria.class}'"
      end

      if self.predicate
        new_predicate = NSCompoundPredicate.andPredicateWithSubpredicates([predicate, new_predicate])
      end

      copy = self.class.new
      %w(entity sortDescriptors fetchLimit fetchOffset resultType).each do |k|
        copy.send("#{k}=", self.send(k))
      end
      copy.predicate = new_predicate
      copy
    end

    private

    def context
      UIApplication.sharedApplication.delegate.managedObjectContext
    end

    def countAll
      _fetchLimit  = self.fetchLimit
      _fetchOffset = self.fetchOffset

      c = self.count

      self.fetchLimit  = _fetchLimit
      self.fetchOffset = _fetchOffset
      c
    end

  end
end