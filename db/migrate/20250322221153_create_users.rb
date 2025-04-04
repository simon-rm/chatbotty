class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :phone_number
      t.string :wa_id
      t.string :session_id
      t.timestamps
    end
  end
end
