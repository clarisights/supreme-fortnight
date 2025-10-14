class AdAccountsController < ApplicationController
  def index
    @ad_accounts = AdAccount.all
  end

  # get all ad_accounts of current user
  def index
    @ad_accounts = AdAccount.where(user_id: current_user.id)
  end
end
