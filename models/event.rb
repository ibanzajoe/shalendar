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
    if !self[:media].blank?
      
      self[:media].map! {|file|
        file = "https://process.filepicker.io/ACGRkMPr9TqmbgPiHBS5Cz/resize=width:500,height:500,fit:crop/rotate=deg:exif/#{file}"
      }
      
    end

    return res
  end

end
