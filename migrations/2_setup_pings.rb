Sequel.migration do
  change do
    create_table(:pings) do
      primary_key :id
      String :url, null: false, default: nil
      String :is_ping, default: true
      String :http_method, default: 'GET'
      index :url
    end
  end
end
