class AdAccountsController < ApplicationController
  def index
    @ad_accounts = AdAccount.all
  end
end
