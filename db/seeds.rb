# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
user = User.create!(email: "mihir.khandekar@clarisights.com", password: "password")
ad_account = AdAccount.create!(name: "Sample Ad Account", user: user)
campaign = ad_account.campaigns.create!(name: "Sample Campaign", objective: "Traffic", start_date: Date.today - 10, end_date: Date.today + 10, daily_budget: 1000, lifetime_budget: 10000, buying_type: "Auction")
ad_set = campaign.ad_sets.create!(name: "Sample Ad Set", optimization_goal: "Clicks", start_date: Date.today - 5, end_date: Date.today + 5, daily_budget: 500, lifetime_budget: 5000, billing_event: "Impressions", bid_strategy: "Lowest Cost")
ad = ad_set.ads.create!(name: "Sample Ad", landing_pages: "https://example.com", ad_type: "Image", ad_format: "Carousel", start_date: Date.today)
ad.metrics.create!(date: Date.today, impressions: 1000, clicks: 138, spend: 85, ctr: 5.0, cpc: 2.0)
