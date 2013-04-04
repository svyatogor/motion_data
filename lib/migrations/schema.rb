class Schema
  include Singleton
  attr_reader :entities

  def initialize
    @entities = []
  end

  def self.define(&block)
    Schema.instance.instance_eval(&block)
  end

  def entity(name, &block)
    _entity = Entity.new(name)
    _entity.instance_eval(&block)
    @entities << _entity
  end

end