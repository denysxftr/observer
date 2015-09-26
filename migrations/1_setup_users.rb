Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :email, null: false, default: nil
      String :name, null: false, default: nil
      String :password_hash, null: false, default: nil
      String :role, null: false, default: 'user'
      index :email
      index [:email, :password_hash]
      index :auth_token
    end
  end
end
