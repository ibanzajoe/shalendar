class UserFollow < Sequel::Model

  plugin :timestamps

  many_to_one :user
  many_to_one :friend, :class => :User

end
