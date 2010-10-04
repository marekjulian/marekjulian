class Port::PortfolioCollectionsController < ApplicationController
  layout "port"

  # GET /port/portfolio/1/portfolio_collections/1
  # GET /port/portfolio/1/portfolio_collections/1.xml
  def show
    @portfolio = Portfolio.find( params[:portfolio_id] )
    @portfolio_collection = PortfolioCollection.find( params[:id] )
    @showCollections = @portfolio.portfolio_collections
    showView = ImageShowView.find( @portfolio_collection.default_show_view_id )
    @mainImageVariant = ImageVariant.find showView.show_variant_id

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @portfolio_collection }
    end
  end

end
