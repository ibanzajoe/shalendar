Sequel.migration do
  up do
    add_column :users, :integrations, :jsonb
  end

  down do

  end
end
