class AddUniquenessToUserAndType < ActiveRecord::Migration
  def up
    add_index :physiqual_tokens, [:type, :physiqual_user_id], unique: true
  end

  def down
    remove_index :physiqual_tokens, [:type, :physiqual_user_id]
  end
end
