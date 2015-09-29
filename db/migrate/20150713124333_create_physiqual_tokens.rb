class CreatePhysiqualTokens < ActiveRecord::Migration
  def change
    create_table :physiqual_tokens do |t|
      t.string :token
      t.string :refresh_token
      t.datetime :valid_until
      t.references :physiqual_user, index: true, foreign_key: true, null: false
      t.string :type, null: false

      t.timestamps null: false
    end
  end
end
