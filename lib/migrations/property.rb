class Property
  attr_reader :attributes

  def initialize(name, options={})
    type = options.delete(:type) || :string

    raise_if_property_type_not_allowed(type)
    options.each { |key, _| raise_if_property_option_not_allowed(type, key) }

    @attributes     = {
        name:          name,
        attributeType: type.to_s.camelize.gsub(/(\d+)/, " \\1"),
        optional:      true.to_core_data_bool,
        syncable:      true.to_core_data_bool
    }
    @attributes.merge!(core_data_property_attributes(type, options))
  end

  def raise_if_property_type_not_allowed(type)
    unless property_type_allowed?(type)
      raise <<-ERROR
! The type must be one of the following:
!  :string
!  :integer_16
!  :integer_32
!  :integer_64
!  :decimal
!  :double
!  :float
!  :boolean
!  :date
!  :binary
      ERROR
    end
  end

  def property_type_allowed?(type)
    [
        :string,
        :integer_16,
        :integer_32,
        :integer_64,
        :decimal,
        :double,
        :float,
        :boolean,
        :date,
        :binary
    ].include?(type)
  end

  def raise_if_property_option_not_allowed(type, option)
    unless property_option_allowed?(type, option)
      raise <<-ERROR
! The option must be one of the following:
!
!   For type :string:
!     :min
!     :max
!     :default
!     :regex
!
!   For type :boolean:
!      :default
!
!   For type :date, :integer_16, :integer_32, :integer_64, :decimal, :double or :float:
!      :min
!      :max
!      :default
!
!   For type :binary:
!      :external_storage
!
!   Options allowed for all types:
!      :required
!      :transient
!      :indexed
!      :spotlight
!      :truth_file
      ERROR
    end
  end

  def property_option_allowed?(type, option)
    type = :number if [
        :integer_16,
        :integer_32,
        :integer_64,
        :decimal,
        :double,
        :float,
        :date
    ].include?(type)

    allowed_options = {
        number: [:min, :max, :default],
        string: [:min, :max, :default, :regex],
        boolean: [:default],
        binary: [:external_storage]
    }[type]

    allowed_options += [
        :required,
        :transient,
        :indexed,
        :spotlight,
        :truth_file
    ]
    allowed_options.include?(option)
  end

  def core_data_property_attributes(type, options)
    attributes = {}

    options.each do |key, value|
      case key
        when :required
          attributes[:optional] = (!value).to_core_data_bool
        when :transient
          attributes[:transient] = value.to_core_data_bool
        when :indexed
          attributes[:indexed] = value.to_core_data_bool
        when :spotlight
          attributes[:spotlightIndexingEnabled] = value.to_core_data_bool
        when :truth_file
          attributes[:storedInTruthFile] = value.to_core_data_bool
        when :min
          if type == :date
            attributes[:minDateTimeInterval] = value.to_core_data_date
          else
            attributes[:minValueString] = value
          end
        when :max
          if type == :date
            attributes[:maxDateTimeInterval] = value.to_core_data_date
          else
            attributes[:maxValueString] = value
          end
        when :default
          if type == :date
            attributes[:defaultDateTimeInterval] = value.to_core_data_date
          elsif type == :boolean
            attributes[:defaultValueString] = value.to_core_data_bool
          else
            attributes[:defaultValueString] = value
          end
        when :regex
          attributes[:regularExpressionString] = value
        when :external_storage
          attributes[:allowsExternalBinaryDataStorage] = value.to_core_data_bool
      end
    end
    attributes
  end
end
