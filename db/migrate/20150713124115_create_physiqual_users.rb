class CreatePhysiqualUsers < ActiveRecord::Migration
  def change
    create_table :physiqual_users do |t|
      t.string :email, null: false

      t.timestamps null: false
    end
    add_index(:physiqual_users, [:email], unique: true)
  end
end
