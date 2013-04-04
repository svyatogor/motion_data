class Relationship
  attr_reader :attributes

  def initialize(name, type, options = {})
    options.each { |key, _| raise_if_relationship_option_not_allowed(type, key) }

    raise_if_deletion_rule_not_allowed(options)

    @attributes = {
        name:          name,
        optional:      true.to_core_data_bool,
        deletion_rule: :no_action.to_s.camelize,
        syncable:      true.to_core_data_bool,
        class_name:    name.to_s.classify
    }
    @attributes.merge!({minCount: 1, maxCount: 1}) if (type == :belongs_to || type == :has_one)
    @attributes.merge!(options)
    @attributes = core_data_relationship_attributes(type, attributes)
  end

  def raise_if_relationship_option_not_allowed(type, option)
    unless relationship_option_allowed?(type, option)
      raise <<-ERROR
! The option must be one of the following:
!
!   For type :belongs_to:
!     :required
!     :deletion_rule
!     :class_name
!     :inverse_of
!     :spotlight
!     :truth_file
!     :transient
!
!   For type :has_many:
!     :required
!     :min
!     :max
!     :deletion_rule
!     :class_name
!     :inverse_of
!     :ordered
!     :spotlight
!     :truth_file
!     :transient
      ERROR
    end
  end

  def deletion_rule_allowed?(options)
    allowed_deletion_rules = [
        :nullify,
        :cascade,
        :deny
    ]
    !options[:deletion_rule] || allowed_deletion_rules.include?(options[:deletion_rule])
  end

  def raise_if_deletion_rule_not_allowed(options)
    unless deletion_rule_allowed?(options)
      raise <<-ERROR
! One of these deletion rules are allowed:
!   :nullify
!   :cascade
!   :deny
      ERROR
    end
  end

  def relationship_option_allowed?(type, option)
    allowed_options = {
        has_many: [:ordered, :min, :max],
    }[type] || []

    allowed_options += [
        :required,
        :spotlight,
        :truth_file,
        :transient,
        :inverse_of,
        :class_name,
        :deletion_rule
    ]
    allowed_options.include?(option)
  end

  def core_data_relationship_attributes(type, options)
    attributes = {}

    options.each do |key, value|
      case key
        when :required
          attributes[:optional] = (!value).to_core_data_bool
        when :inverse_of
          attributes[:inverseName] = value
        when :class_name
          attributes[:inverseEntity]     = value
          attributes[:destinationEntity] = value
        when :deletion_rule
          attributes[:deletionRule] = value.to_s.camelize
        when :transient
          attributes[:transient] = value.to_core_data_bool
        when :spotlight
          attributes[:spotlightIndexingEnabled] = value.to_core_data_bool
        when :truth_file
          attributes[:storedInTruthFile] = value.to_core_data_bool
        when :min
          attributes[:minCount] = value
        when :max
          attributes[:maxCount] = value
        else
          attributes[key] = value
      end
    end
    attributes[:toMany] = (type == :has_many).to_core_data_bool
    attributes
  end
end
