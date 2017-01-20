Sequel.migration do
  up do
    create_table :media do
      primary_key :id
      Fixnum :user_id, :index => true
      Fixnum :event_id, :index => true
      String :provider, :index => true

      String :refid, :index => true
      String :type, :index => true
      String :title
      String :description
      String :image_url
      String :video_url
      column :data, 'jsonb'
      DateTime :origin_at

      DateTime :created_at
      DateTime :updated_at
      unique [:provider, :refid]
      index [:user_id, :provider]
    end
  end

  down do
    drop_table :medias
  end
end
