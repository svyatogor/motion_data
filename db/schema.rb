Schema.define do
	entity :parent_model do
		property :string_value
		property :int_value, type: :integer_16
		property :x_raw, type: :binary
	end
end