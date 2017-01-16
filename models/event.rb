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
    res[:calendar] = Calendar.where(:id => self[:calendar_id], :user_id => self[:user_id]).first
    if !self[:media].blank? && (self[:media].respond_to? :map)
      self[:media].map! {|file|
        file = "https://process.filepicker.io/ACGRkMPr9TqmbgPiHBS5Cz/resize=width:500,height:500,fit:crop/rotate=deg:exif/#{file}"
      }
    end
    return res
  end

end
