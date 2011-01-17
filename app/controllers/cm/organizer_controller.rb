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

    def create_new_collection_tab
        logger.debug "cm/organizer_controller/create_new_collection_tag - inspecting params:"
        logger.debug params.inspect

        @archive = Archive.find params[:archive_id]
        @collection = Collection.find params[:collection_id]

        tabs_list_item_id = "OrganizerWorkspaceBodyCollection-" + params[:collection_id] + "-tab"
        tabs_list_item_close_id = "OrganizerWorkspaceBodyCollection-" + params[:collection_id] + "-close"
        tab_content_id = "OrganizerWorkspaceBodyCollection-" + params[:collection_id]
        tabs_list_item = render_to_string :partial => "create_tabs_list_item", :locals => {  :tabs_list_item_id => tabs_list_item_id,
                                                                                             :tabs_list_item_close_id => tabs_list_item_close_id,
                                                                                             :tab_content_id => tab_content_id,
                                                                                             :tab_name => "Collection: " + @collection.tag_line }
        tab_content_div = render_to_string :partial => "create_collection_tab_content_div",
                                           :locals => {  :tab_content_id => tab_content_id,
                                                         :collection => @collection }

        render :update do |page|
            page.insert_html :bottom, 'OrganizerWorkspaceTabsList', tabs_list_item
            page.insert_html :bottom, 'OrganizerWorkspaceBody', tab_content_div
            page << "tabsControl.addTab( $( '#{ tabs_list_item_id}' ).down().down() )"
            page << "tabsControl.setActiveTab( $( '#{tabs_list_item_id}' ).down().down() )"
        end
    end

    def create_new_portfolio_collection_tab
        logger.debug "cm/organizer_controller/create_new_portfolio_collection_tag - inspecting params:"
        logger.debug params.inspect

        @archive = Archive.find params[:archive_id]
        @portfolio_collection = PortfolioCollection.find params[:portfolio_collection_id]

        tabs_list_item_id = "OrganizerWorkspaceBodyPortfolioCollection-" + params[:portfolio_collection_id] + "-tab"
        tabs_list_item_close_id = "OrganizerWorkspaceBodyPortfolioCollection-" + params[:portfolio_collection_id] + "-close"
        tab_content_id = "OrganizerWorkspaceBodyPortfolioCollection-" + params[:portfolio_collection_id]
        tabs_list_item = render_to_string :partial => "create_tabs_list_item", :locals => {  :tabs_list_item_id => tabs_list_item_id,
                                                                                             :tabs_list_item_close_id => tabs_list_item_close_id,
                                                                                             :tab_content_id => tab_content_id,
                                                                                             :tab_name => "Portfolio: " + @portfolio_collection.collection.tag_line }
        tab_content_div = render_to_string :partial => "create_portfolio_collection_tab_content_div",
                                           :locals => {  :tab_content_id => tab_content_id,
                                           :portfolio_collection => @portfolio_collection }

        render :update do |page|
            page.insert_html :bottom, 'OrganizerWorkspaceTabsList', tabs_list_item
            page.insert_html :bottom, 'OrganizerWorkspaceBody', tab_content_div
            page << "tabsControl.addTab( $( '#{ tabs_list_item_id}' ).down().down() )"
            page << "tabsControl.setActiveTab( $( '#{tabs_list_item_id}' ).down().down() )"
        end
    end

end
