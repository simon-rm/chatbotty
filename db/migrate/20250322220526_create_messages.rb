class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.text :text
      t.boolean :human
      t.references :conversation, null: false

      t.timestamps
    end
  end
end
