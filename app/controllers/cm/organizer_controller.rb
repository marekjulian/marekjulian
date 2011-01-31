class Cm::OrganizerController < ApplicationController

    before_filter :login_required

    layout "cm/organizer"

    def show

        logger.debug "Showing session at start:"
        logger.debug session.inspect

        @archive = Archive.find( params[:archive_id] )

        logger.debug "Showing session at end:"
        logger.debug session.inspect

        respond_to do |format|
            format.html
        end

    end

    def update_preview_for_collections_tab

    end

    def update_preview_for_portfolios_tab
    end

    def update_preview_for_collection_instance_tab
    end

    def update_preview_for_portfolio_instance_tab
    end

    def update_preview_for_portfolio_collection_instance_tab
    end

    def update_preview_content_for_collections_tab
        logger.debug "update_preview_content: params - "
        logger.debug params.inspect
        @archive = Archive.find( params[:archive_id] )
        if params['selected-collection-id'] == 'all'
            images = []
            @archive.collections.each do |collection|
                collection.images.each do |image|
                    images.push(image)
                end
            end
        else
            collection = Collection.find( params['selected-collection-id'] )
            images = collection.images
        end
        render :update do |page|
            page.replace_html 'organizer-preview-content', :partial => 'preview_content_for_collections_tab', :locals => { :images => images }
        end
    end

    def update_preview_content_for_portfolios_tab
        render :update do |page|
        end
    end

    def update_preview_content_for_collection_instance_tab
        render :update do |page|
        end
    end

    def update_preview_content_for_portfolio_instance_tab
        render :update do |page|
        end
    end

    def update_preview_content_for_portfolio_collection_instance_tab
        render :update do |page|
        end
    end

    def create_new_collection_instance_tab
        logger.debug "cm/organizer_controller/create_new_collection_instance_tag - inspecting params:"
        logger.debug params.inspect

        @archive = Archive.find params[:archive_id]
        @collection = Collection.find params[:collection_id]

        tabs_list_item_id = "organizer-workspace-body-collection-" + params[:collection_id] + "-tab"
        tabs_list_item_close_id = "organizer-workspace-body-collection-" + params[:collection_id] + "-close"
        tab_content_id = "organizer-workspace-body-collection-" + params[:collection_id]
        tabs_list_item = render_to_string :partial => "create_tabs_list_item", :locals => {  :tabs_list_item_id => tabs_list_item_id,
                                                                                             :tabs_list_item_close_id => tabs_list_item_close_id,
                                                                                             :tab_content_id => tab_content_id,
                                                                                             :tab_name => "Collection: " + @collection.tag_line }
        tab_content_div = render_to_string :partial => "create_collection_instance_tab_content_div",
                                           :locals => {  :tab_content_id => tab_content_id,
                                                         :collection => @collection }

        render :update do |page|
            page.insert_html :bottom, 'organizer-workspace-tabs-list', tabs_list_item
            page.insert_html :bottom, 'organizer-workspace-body', tab_content_div
            page << "tabsControl.addTab( $( '#{ tabs_list_item_id}' ).down().down() )"
            page << "tabsControl.setActiveTab( $( '#{tabs_list_item_id}' ).down().down() )"
        end
    end

    def create_new_portfolio_instance_tab
        @archive = Archive.find params[:archive_id]
        @portfolio = Portfolio.find params[:portfolio_id]

        tabs_list_item_id = "organizer-workspace-body-portfolio-" + params[:portfolio_id] + "-tab"
        tabs_list_item_close_id = "organizer-workspace-body-portfolio-" + params[:portfolio_id] + "-close"
        tab_content_id = "organizer-workspace-body-portfolio-" + params[:portfolio_id]
        tabs_list_item = render_to_string :partial => "create_tabs_list_item", :locals => {  :tabs_list_item_id => tabs_list_item_id,
                                                                                             :tabs_list_item_close_id => tabs_list_item_close_id,
                                                                                             :tab_content_id => tab_content_id,
                                                                                             :tab_name => "Portfolio: " + @portfolio.description }
        tab_content_div = render_to_string :partial => "create_portfolio_instance_tab_content_div",
                                           :locals => {  :tab_content_id => tab_content_id,
                                                         :portfolio => @portfolio }

        render :update do |page|
            page.insert_html :bottom, 'organizer-workspace-tabs-list', tabs_list_item
            page.insert_html :bottom, 'organizer-workspace-body', tab_content_div
            page << "tabsControl.addTab( $( '#{ tabs_list_item_id}' ).down().down() )"
            page << "tabsControl.setActiveTab( $( '#{tabs_list_item_id}' ).down().down() )"
        end
    end

    def create_new_portfolio_collection_instance_tab
        logger.debug "cm/organizer_controller/create_new_portfolio_instance_tag - inspecting params:"
        logger.debug params.inspect

        @archive = Archive.find params[:archive_id]
        @portfolio_collection = PortfolioCollection.find params[:portfolio_collection_id]

        tabs_list_item_id = "organizer-workspace-body-portfolio-collection-" + params[:portfolio_collection_id] + "-tab"
        tabs_list_item_close_id = "organizer-workspace-body-portfolio-Collection-" + params[:portfolio_collection_id] + "-close"
        tab_content_id = "organizer-workspace-body-portfolio-collection-" + params[:portfolio_collection_id]
        tabs_list_item = render_to_string :partial => "create_tabs_list_item", :locals => {  :tabs_list_item_id => tabs_list_item_id,
                                                                                             :tabs_list_item_close_id => tabs_list_item_close_id,
                                                                                             :tab_content_id => tab_content_id,
                                                                                             :tab_name => "Portfolio collection: " + @portfolio_collection.collection.tag_line }
        tab_content_div = render_to_string :partial => "create_portfolio_collection_instance_tab_content_div",
                                           :locals => {  :tab_content_id => tab_content_id,
                                           :portfolio_collection => @portfolio_collection }

        render :update do |page|
            page.insert_html :bottom, 'organizer-workspace-tabs-list', tabs_list_item
            page.insert_html :bottom, 'organizer-workspace-body', tab_content_div
            page << "tabsControl.addTab( $( '#{ tabs_list_item_id}' ).down().down() )"
            page << "tabsControl.setActiveTab( $( '#{tabs_list_item_id}' ).down().down() )"
        end
    end

end
