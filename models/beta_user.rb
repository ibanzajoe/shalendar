class BetaUser < Sequel::Model

  plugin :timestamps

  many_to_one :user

end
