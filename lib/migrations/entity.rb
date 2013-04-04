class Entity
  attr_reader :name, :properties, :relationships
  def initialize(name)
    @name          = name
    @properties    = []
    @relationships = []
  end

  def property(name, options = {})
    @properties << Property.new(name, options)
  end

  def has_one(name, options={})
    @relationships << Relationship.new(name, :belongs_to, options)
  end

  def belongs_to(name, options={})
    @relationships << Relationship.new(name, :belongs_to, options)
  end

  def has_many(name, options={})
    @relationships << Relationship.new(name, :has_many, options)
  end
end
