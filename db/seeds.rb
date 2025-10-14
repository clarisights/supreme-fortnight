# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# user = User.create!(email: "mihir.khandekar@clarisights.com", password: "password")
# ad_account = AdAccount.create!(name: "Sample Ad Account", user: user)
# campaign = ad_account.campaigns.create!(name: "Sample Campaign", objective: "Traffic", start_date: Date.today - 10, end_date: Date.today + 10, daily_budget: 1000, lifetime_budget: 10000, buying_type: "Auction")
# ad_set = campaign.ad_sets.create!(name: "Sample Ad Set", optimization_goal: "Clicks", start_date: Date.today - 5, end_date: Date.today + 5, daily_budget: 500, lifetime_budget: 5000, billing_event: "Impressions", bid_strategy: "Lowest Cost")
# ad = ad_set.ads.create!(name: "Sample Ad", landing_pages: "https://example.com", ad_type: "Image", ad_format: "Carousel", start_date: Date.today)
# ad.metrics.create!(date: Date.today, impressions: 1000, clicks: 138, spend: 85, ctr: 5.0, cpc: 2.0)
# 
require 'net/http'
require 'json'

# Replace with your list of ad account IDs and access token
AD_ACCOUNT_IDS = ["act_524531534411283","act_802973356567098","act_273283240061513","act_280463189370596","act_2416286235360237","act_816047362146288"]
ACCESS_TOKEN = 'EAAKDX99BZAz4BOZCGNi84c9ZAT0jeDX8xvJ1TE5eNxKwM91uQZCx9ew5Ntym8Gpfz3gfj2hoJVsuNaZAmxuNClWa9W2qoasByyZCYdywv6BefIiFLjxduEmliCYKmNYZByhr9QEa64vkKzP3ZBfWuPQYOEOrcUW8t22TLBHjjOqQpZCPD3R5ZAW1F5snZCZAAmPsr2Gk'

# Helper method to make API requests
def fetch_facebook_data(url)
  uri = URI(url)
  response = Net::HTTP.get(uri)
  JSON.parse(response)
end

# Seed Ad Accounts, Campaigns, Ad Sets, Ads, and Metrics
AD_ACCOUNT_IDS.each do |ad_account_id|
  puts "Fetching data for ad account: #{ad_account_id}"

  # Fetch ad account details
  ad_account_url = "https://graph.facebook.com/v21.0/#{ad_account_id}?fields=name&access_token=#{ACCESS_TOKEN}"
  ad_account_data = fetch_facebook_data(ad_account_url)

  ad_account = AdAccount.find_or_create_by(id: ad_account_id.split('_').last.to_i) do |account|
    account.name = ad_account_data['name']
    account.user_id = 1 # Replace with a valid user ID
  end

  # Fetch campaigns
  campaigns_url = "https://graph.facebook.com/v21.0/#{ad_account_id}/campaigns?fields=id,name,objective,start_time,stop_time&access_token=#{ACCESS_TOKEN}"
  campaigns_data = fetch_facebook_data(campaigns_url)['data']

  campaigns_data.each do |campaign_data|
    campaign = Campaign.find_or_create_by(id: campaign_data['id']) do |c|
      c.name = campaign_data['name']
      c.objective = campaign_data['objective']
      c.start_date = campaign_data['start_time']
      c.end_date = campaign_data['stop_time']
      c.ad_account_id = ad_account.id
    end

    # Fetch ad sets
    ad_sets_url = "https://graph.facebook.com/v21.0/#{campaign_data['id']}/adsets?fields=id,name,budget_remaining,start_time,end_time&access_token=#{ACCESS_TOKEN}"
    ad_sets_data = fetch_facebook_data(ad_sets_url)['data']

    ad_sets_data.each do |ad_set_data|
      ad_set = AdSet.find_or_create_by(id: ad_set_data['id']) do |as|
        as.name = ad_set_data['name']
        as.start_date = ad_set_data['start_time']
        as.end_date = ad_set_data['end_time']
        as.daily_budget = ad_set_data['budget_remaining'] # Assuming budget_remaining is daily budget
        as.campaign_id = campaign.id
      end

      # Fetch ads
      ads_url = "https://graph.facebook.com/v21.0/#{ad_set_data['id']}/ads?fields=id,name,effective_status,created_time&access_token=#{ACCESS_TOKEN}"
      ads_data = fetch_facebook_data(ads_url)['data']

      ads_data.each do |ad_data|
        ad = Ad.find_or_create_by(id: ad_data['id']) do |a|
          a.name = ad_data['name']
          a.start_date = ad_data['created_time']
          a.ad_set_id = ad_set.id
        end

        # Fetch metrics
        metrics_url = "https://graph.facebook.com/v21.0/#{ad_data['id']}/insights?fields=impressions,clicks,spend,ctr,actions&access_token=#{ACCESS_TOKEN}"
        metrics_data = fetch_facebook_data(metrics_url)['data']
        
        # add nil check for metrics_data
        if metrics_data
          metrics_data.each do |metric_data|
            Metric.create!(
              ad_id: ad.id,
              date: metric_data['date_start'],
              impressions: metric_data['impressions'].to_i,
              clicks: metric_data['clicks'].to_i,
              spend: metric_data['spend'].to_f,
              ctr: metric_data['ctr'].to_f,
              all_clicks: metric_data['actions']&.find { |a| a['action_type'] == 'link_click' }&.dig('value').to_i || 0,
              likes: metric_data['actions']&.find { |a| a['action_type'] == 'post_reaction' }&.dig('value').to_i || 0,
              comments: metric_data['actions']&.find { |a| a['action_type'] == 'comment' }&.dig('value').to_i || 0,
              video_plays: metric_data['actions']&.find { |a| a['action_type'] == 'video_view' }&.dig('value').to_i || 0
            )
          end
        end
      end
    end
  end
end

puts "Seeding completed!"
