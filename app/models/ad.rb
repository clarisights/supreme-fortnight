class Ad < ApplicationRecord
  belongs_to :ad_set
  has_many :metrics
end
