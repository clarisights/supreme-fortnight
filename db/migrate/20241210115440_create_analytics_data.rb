class CreateAnalyticsData < ActiveRecord::Migration[8.0]
  def change
    create_table :analytics_data do |t|
      t.string :campaign_name
      t.string :adset_name
      t.string :ad_name
      t.integer :revenue
      t.date :date

      t.timestamps
    end
  end
end
