class AddNoteToRecordings < ActiveRecord::Migration[7.0]
  def change
    add_column :recordings, :note, :string
  end
end
