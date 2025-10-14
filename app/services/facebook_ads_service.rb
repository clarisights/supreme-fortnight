class FacebookAdsService < BaseDataSource
  def initialize(ad_account)
    @ad_account = ad_account

    # this is a trivialized implementation of the access token provider
    # in a real-world scenario, this would come from an API/Vault
    @access_token = SourceAccessTokens.new.call
    @api_base_url = "https://graph.facebook.com/v21.0"
  end

  def fetch_metrics(start_date:, end_date:)
    url = "#{@api_base_url}/#{@ad_account}/insights"
    params = {
      access_token: @access_token,
      level: "ad",
      fields: "impressions,clicks,spend,link_clicks,ctr,cpc",
      time_range: { since: start_date.to_s, until: end_date.to_s }
    }

    response = HTTParty.get(url, query: params)
    if response.success?
      parse_metrics(response.parsed_response)
    else
      Rails.logger.error "Failed to fetch metrics for #{@ad_account.name}: #{response.body}"
      []
    end
  end

  def parse_metrics(data)
    data['data'].map do |metric|
      {
        ad_id: metric['ad_id'],
        date: metric['date_start'],
        impressions: metric['impressions'].to_i,
        clicks: metric['clicks'].to_i,
        spend: metric['spend'].to_f,
        link_clicks: metric['link_clicks'].to_i,
        ctr: metric['ctr'].to_f,
        cpc: metric['cpc'].to_f
      }
    end
  end
end