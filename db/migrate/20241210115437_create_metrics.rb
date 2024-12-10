class CreateMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :metrics do |t|
      t.references :ad, null: false, foreign_key: true
      t.date :date
      t.integer :impressions
      t.integer :all_clicks
      t.integer :clicks
      t.integer :spend
      t.float :all_ctr
      t.float :ctr
      t.float :cplc
      t.float :cpc
      t.integer :comments
      t.integer :likes
      t.integer :landing_page_views
      t.integer :mobile_app_installs
      t.integer :video_plays
      t.integer :conversions

      t.timestamps
    end
  end
end
