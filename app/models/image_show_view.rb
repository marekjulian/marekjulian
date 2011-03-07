class ImageShowView < ActiveRecord::Base

  belongs_to :image
  belongs_to :portfolio_collection

  before_destroy :remove_references

  protected

    def remove_references
        logger.debug "ImageShowView.remove_references - "
        portfolio_collections = PortfolioCollection.find(:all)
        portfolio_collections.each do |pc|
            if pc.default_show_view_id == id
                pc.default_show_view_id = nil
                pc.save
            end
        end
        portfolios = Portfolio.find(:all)
        portfolios.each do |p|
            if p.default_show_view_id == id
                p.default_show_view_id = nil
                p.save
            end
        end
    end

end
