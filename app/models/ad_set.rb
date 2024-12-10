class AdSet < ApplicationRecord
  belongs_to :campaign
  has_many :ads
end
