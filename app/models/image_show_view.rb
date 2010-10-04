class ImageShowView < ActiveRecord::Base

  belongs_to :image
  belongs_to :portfolio_collection

end
