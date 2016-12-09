Sequel.migration do
  up do
    create_table :calendars do
      primary_key :id
      Fixnum :user_id
      String :name, :size => 64
      Fixnum :rank, :default => 0
      String :color, :size => 64
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :calendars
  end
end
