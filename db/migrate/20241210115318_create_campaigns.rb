class CreateCampaigns < ActiveRecord::Migration[8.0]
  def change
    create_table :campaigns do |t|
      t.string :name
      t.string :objective
      t.date :start_date
      t.date :end_date
      t.integer :daily_budget
      t.integer :lifetime_budget
      t.string :buying_type
      t.references :ad_account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
