class CreateEbooks < ActiveRecord::Migration[7.1]
  def change
    create_table :ebooks do |t|
      t.string :title, null: false
      t.string :author

      t.timestamps
    end

    add_index :ebooks, :title
    add_index :ebooks, :author
  end
end
