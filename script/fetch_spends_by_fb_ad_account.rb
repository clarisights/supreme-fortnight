require 'net/http'
require 'uri'
require 'json'

# accept token as a command line argument token
ACCESS_TOKEN = ARGV[0]

ad_account_ids = ["act_524531534411283",
"act_802973356567098",
"act_273283240061513",
"act_280463189370596",
"act_2416286235360237",
"act_816047362146288",]

API_BASE_URL = 'https://graph.facebook.com/v21.0'

def fetch_spend(ad_account_id)
  uri = URI("#{API_BASE_URL}/#{ad_account_id}/insights")

  params = {
    'access_token' => ACCESS_TOKEN,
    'fields' => 'spend',
    'date_preset' => 'last_30d',
    # 'filtering' => [{ 'field' => 'status', 'operator' => 'EQUAL', 'value' => 'ACTIVE' }].to_json
  }
  uri.query = URI.encode_www_form(params)

  response = Net::HTTP.get_response(uri)

  if response.is_a?(Net::HTTPSuccess)
    data = JSON.parse(response.body)
    if data['data'] && !data['data'].empty?
      data['data'][0]['spend'] # Return the spend value
    else
      "No data available"
    end
  else
    "Error: #{response.message}"
  end
end

ad_account_ids.each do |ad_account_id|
  spend = fetch_spend(ad_account_id)
  puts "Ad Account #{ad_account_id}: Spend = #{spend}"
end


# act_524531534411283/campaigns?fields=lifetime_budget,budget_remaining,objective,name,bid_strategy,buying_type,status,start_time,stop_time,insights{cpc,impressions,objective,spend}