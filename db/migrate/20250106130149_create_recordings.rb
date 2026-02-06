class CreateRecordings < ActiveRecord::Migration[7.0]
  def change
    create_table :recordings do |t|
      t.integer :amount, null: false
      t.date :recorded_date, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
