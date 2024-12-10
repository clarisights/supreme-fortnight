class CreateAds < ActiveRecord::Migration[8.0]
  def change
    create_table :ads do |t|
      t.string :name
      t.string :landing_pages
      t.string :ad_type
      t.string :ad_format
      t.date :start_date
      t.string :facebook_post
      t.string :instagram_post
      t.references :ad_set, null: false, foreign_key: true

      t.timestamps
    end
  end
end
