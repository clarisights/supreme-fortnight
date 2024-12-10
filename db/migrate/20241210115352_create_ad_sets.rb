class CreateAdSets < ActiveRecord::Migration[8.0]
  def change
    create_table :ad_sets do |t|
      t.string :name
      t.string :optimization_goal
      t.date :start_date
      t.date :end_date
      t.integer :daily_budget
      t.integer :lifetime_budget
      t.string :billing_event
      t.string :bid_strategy
      t.references :campaign, null: false, foreign_key: true

      t.timestamps
    end
  end
end
