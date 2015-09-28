Sequel.migration do
  change do
    create_table(:pings) do
      primary_key :id
      String :url, null: false, default: nil
      Boolean :is_ping, default: true
      String :http_method, default: 'GET'
      Boolean :is_ok, default: true
      Integer :last_response_time, default: nil
      index :url
      index :is_ping
    end
  end
end
