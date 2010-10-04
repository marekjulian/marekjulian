class PortfolioCollection < ActiveRecord::Base

  belongs_to    :portfolio
  belongs_to    :collection
  has_many :image_show_views

end
