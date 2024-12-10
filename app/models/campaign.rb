class Campaign < ApplicationRecord
  belongs_to :ad_account
  has_many :ad_sets
end
