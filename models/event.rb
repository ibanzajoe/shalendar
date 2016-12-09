class Event < Sequel::Model
  plugin :timestamps
  many_to_one :user

  def before_save
    super
  end

  def formatted
    res = self
    res[:start] = self[:starts_at]
    res[:end] = self[:ends_at]
    return res
  end

end
