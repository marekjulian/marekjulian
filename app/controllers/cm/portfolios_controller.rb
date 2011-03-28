class Cm::PortfoliosController < ApplicationController

    before_filter :login_required
    before_filter :load_params
    before_filter :verify_portfolio

    layout "cm/cm"

    def show
        @archive = Archive.find(params[:archive_id])
        @portfolio = Portfolio.find(params[:id])
    end

    protected

        def load_params
            @archive = Archive.find( params[:archive_id] )
            @portfolio = nil
            if params[:id]
                @portfolio = Portfolio.find( params[:id] )
            end
        end

        def verify_portfolio
            logger.info "verify_portfolio..."

            deleted_image_show_views = false
            @portfolio.portfolio_collections.each do |portfolio_collection|
                begin
                    default_show_view = ImageVariant.find( portfolio_collection.default_show_view_id )
                rescue
                    portfolio_collection.default_show_view_id = nil
                end
                portfolio_collection.image_show_views.each do |image_show_view|
                    had_missing_views = false
                    begin
                        show_iv = ImageVariant.find( image_show_view.show_variant_id )
                    rescue
                        show_iv = nil
                        had_missing_views = true
                    end
                    begin
                        thumbnail_iv = ImageVariant.find( image_show_view.thumbnail_variant_id )
                    rescue
                        show_iv = nil
                        had_missing_views = true
                    end
                    if had_missing_views
                        logger.info "portfolios_controller.verify_portfolio - destroying image_show_view..."
                        image_show_view.destroy
                        deleted_image_show_views = true
                    else
                        if portfolio_collection.default_show_view_id == nil
                            portfolio_collection.default_show_view_id = image_show_view.id
                            portfolio_collection.save
                        end
                    end
                end
            end
            if deleted_image_show_views
                logger.info "portfolios_controller.verify_portfolio - saving portfolio..."
                @portfolio.save
            end
        end
end
