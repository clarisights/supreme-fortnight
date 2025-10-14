class FetchFacebookAdMetrics < ApplicationJob
  queue_as :default

  def perform
    AdAccount.find_each do |ad_account|
      fetch_metrics(ad_account.id)
    end
  end

  def fetch_metrics(ad_account)
    metrics = FacebookAdsService.new(ad_account).fetch_metrics

    puts "Fetched #{metrics.size} metrics for ad account: #{ad_account.name}"
    metrics.each do |metric|
      Metric.create!(
        ad_account_id: ad_account.id,
        date: metric[:date],
        impressions: metric[:impressions],
        clicks: metric[:clicks],
        spend: metric[:spend],
        link_clicks: metric[:link_clicks],
        ctr: metric[:ctr],
        cpc: metric[:cpc]
      )
    end
  end
end