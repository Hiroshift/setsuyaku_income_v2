class RemoveTotalIncomeFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :total_income, :integer, default: 0, null: false
  end
end
