class Media < Sequel::Model
  plugin :timestamps

  def after_create
    super
  end

end
