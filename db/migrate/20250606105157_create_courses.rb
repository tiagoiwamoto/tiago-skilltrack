class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string :title
      t.string :category
      t.date :earn_date
      t.string :school
      t.string :image_src
      t.string :image_src_thumb

      t.timestamps
    end
  end
end
