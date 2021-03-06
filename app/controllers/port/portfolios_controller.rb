class Port::PortfoliosController < ApplicationController
    layout "port/port"

    # GET /portfolios/1
    # GET /portfolios/1.xml
    def show
        @portfolio = Portfolio.find(params[:id])
        @showCollections = @portfolio.portfolio_collections
        @portfolio_collection = nil
        if @portfolio.default_show_view_id
            showView = ImageShowView.find( @portfolio.default_show_view_id )
            @mainImageVariant = ImageVariant.find showView.show_variant_id
        else
            @mainImageVariant = nil
        end
        respond_to do |format|
            format.html # show.html.erb
            format.xml  { render :xml => @portfolio }
        end
    end

end
