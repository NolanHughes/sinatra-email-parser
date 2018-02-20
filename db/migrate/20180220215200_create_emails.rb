class CreateEmails < ActiveRecord::Migration[5.1]
  def change
    create_table :emails do |t|
      t.string :file_name
      t.string :subject
      t.text :body
      t.string :attachment_names
      t.string :to
      t.string :from
    end
  end
end
