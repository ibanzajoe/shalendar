class Media < Sequel::Model
  plugin :timestamps

  def after_create
    calendar = Calendar.where(:user_id => self[:user_id], :name => 'Instagram').first
    media = []
    media << self[:image_url]

    event = Event.create(
      :user_id => self[:user_id],
      :calendar_id => calendar[:id],
      :title => self[:title],
      :description => self[:description],
      :media => media.to_json,
      :starts_at => self[:origin_at],
      :ends_at => self[:origin_at],
    )

    self.update(:event_id => event[:id])

    super
  end

end
