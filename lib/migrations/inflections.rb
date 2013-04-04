class TrueClass
  def to_core_data_bool
    "YES"
  end
end

class FalseClass
  def to_core_data_bool
    "NO"
  end
end

class String
  def to_core_data_date(value)
    (self.to_time.to_i - Date.new(2001, 1, 1).to_time.to_i).to_s
  end
end