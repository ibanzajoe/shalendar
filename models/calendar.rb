class Calendar < Sequel::Model
  plugin :timestamps

  def self.colors
    return ['#ffd2ac', '#f5e4f5', '#BCF4EF', '#e9e2f2', '#f2e2e5', '#e3e2f2', '#dbeef7', '#dbf7ed', '#f3f7db', '#f7efdb', '#f7e0db']
  end
end
