class AnalyticsDataController < ApplicationController
  def index
    @analytics_data = AnalyticsDatum.all
  end
end
