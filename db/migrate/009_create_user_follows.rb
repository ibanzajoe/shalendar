Sequel.migration do
  up do
    create_table :user_follows do
      primary_key :id
      Fixnum :user_id, :index => true
      Fixnum :friend_id, :index => true
      DateTime :created_at
      DateTime :updated_at
      unique [:user_id, :friend_id]
    end
  end

  down do
  end
end
