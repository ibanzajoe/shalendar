Sequel.migration do
  up do

    create_table :beta_users do
      primary_key :id
      String :email, :index => true
      String :name
      String :message
      String :phone
      String :access_code
      DateTime :created_at
      DateTime :updated_at
      unique [:email]
    end


  end

  down do
  end
end
