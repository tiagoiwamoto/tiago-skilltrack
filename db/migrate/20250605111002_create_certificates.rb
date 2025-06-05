class CreateCertificates < ActiveRecord::Migration[8.0]
  def change
    create_table :certificates do |t|
      t.string :title
      t.date :earn_date
      t.date :expire_date
      t.string :image_src
      t.string :image_src_thumb

      t.timestamps
    end
  end
end
