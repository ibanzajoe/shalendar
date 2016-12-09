Sequel.migration do
  up do
    create_table :events do
      primary_key :id
      Fixnum :user_id
      Fixnum :calendar_id
      Fixnum :source_id

      String :title, :size => 64
      String :description
      String :url, :size => 128

      String :location
      String :color

      DateTime :starts_at
      DateTime :ends_at

      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :events
  end
end
