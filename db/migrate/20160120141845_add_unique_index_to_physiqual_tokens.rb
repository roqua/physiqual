class AddUniqueIndexToPhysiqualTokens < ActiveRecord::Migration
  def up
    remove_index :physiqual_tokens, [:type, :physiqual_user_id]
    remove_index :physiqual_tokens, [:physiqual_user_id]
    add_index :physiqual_tokens, [:physiqual_user_id], unique: true
  end

  def down
    remove_index :physiqual_tokens, [:physiqual_user_id]
    add_index :physiqual_tokens, [:physiqual_user_id]
    add_index :physiqual_tokens, [:type, :physiqual_user_id], unique: true
  end
end
