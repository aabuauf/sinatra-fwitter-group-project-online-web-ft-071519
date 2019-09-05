class CreateTweetsTable < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :title
      t.string :content
      t.integer :user_id
    end
  end
end
