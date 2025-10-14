class SourceAccessTokens < ApplicationService
  def initialize(source)
    @source = source
  end

  def call
    return Rails.application.credentials.FACEBOOK_API_ACCESS_TOKEN_MANAS_PRAKASH
  end
end
