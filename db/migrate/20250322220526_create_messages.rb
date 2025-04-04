class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.text :text
      t.string :mid
      t.boolean :bot, default: false
      t.integer :platform,  default: 0
      t.references :user, null: false

      t.timestamps
    end
  end
end
