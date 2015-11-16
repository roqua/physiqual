class RenameEmailToUserId < ActiveRecord::Migration
  def up
    rename_column :physiqual_users, :email, :user_id
  end

  def down
    rename_column :physiqual_users, :user_id, :email
  end
end
