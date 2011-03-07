class Cm::OrganizerController < ApplicationController

    before_filter :login_required

    skip_before_filter :verify_authenticity_token,
                       :only => [:create_collection_form,
                                 :delete_collection_form,
                                 :create_portfolio_form,
                                 :delete_portfolio_form,
                                 :create_portfolio_collection_form,
                                 :delete_portfolio_collection_form]

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
        tabs_list_item = render_to_string :partial => "workspace_tabs_list_item", :locals => {  :tabs_list_item_id => tabs_list_item_id,
                                                                                                :tabs_list_item_close_id => tabs_list_item_close_id,
                                                                                                :tab_content_id => tab_content_id,
                                                                                                :tab_name => "Collection: " + @collection.tag_line }
        tab_content_div = render_to_string :partial => "workspace_collection_instance_tab_content_div",
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
        logger.debug "cm/organizer_controller/create_new_portfolio_instance_tab"
        logger.debug params.inspect

        @archive = Archive.find params[:archive_id]
        @portfolio = Portfolio.find params[:portfolio_id]

        tabs_list_item_id = "organizer-workspace-body-portfolio-" + params[:portfolio_id] + "-tab"
        tabs_list_item_close_id = "organizer-workspace-body-portfolio-" + params[:portfolio_id] + "-close"
        tab_content_id = "organizer-workspace-body-portfolio-" + params[:portfolio_id]
        tabs_list_item = render_to_string :partial => "workspace_tabs_list_item", :locals => {  :tabs_list_item_id => tabs_list_item_id,
                                                                                                :tabs_list_item_close_id => tabs_list_item_close_id,
                                                                                                :tab_content_id => tab_content_id,
                                                                                                :tab_name => "Portfolio: " + @portfolio.description }
        tab_content_div = render_to_string :partial => "workspace_portfolio_instance_tab_content_div",
                                           :locals => { :archive => @archive,
                                                        :portfolio => @portfolio,
                                                        :tab_content_id => tab_content_id,
                                                        :initial_render => false }

        render :update do |page|
            page.insert_html :bottom, 'organizer-workspace-tabs-list', tabs_list_item
            page.insert_html :bottom, 'organizer-workspace-body', tab_content_div
            page << "tabsControl.addTab( $( '#{ tabs_list_item_id}' ).down().down() )"
            page << "tabsControl.setActiveTab( $( '#{tabs_list_item_id}' ).down().down() )"
        end
    end

    def create_new_portfolio_collection_instance_tab
        logger.debug "cm/organizer_controller/create_new_portfolio_collection_instance_tab - inspecting params:"
        logger.debug params.inspect

        @archive = Archive.find params[:archive_id]
        @portfolio_collection = PortfolioCollection.find params[:portfolio_collection_id]

        tabs_list_item_id = "organizer-workspace-body-portfolio-collection-" + params[:portfolio_collection_id] + "-tab"
        tabs_list_item_close_id = "organizer-workspace-body-portfolio-Collection-" + params[:portfolio_collection_id] + "-close"
        tab_content_id = "organizer-workspace-body-portfolio-collection-" + params[:portfolio_collection_id]
        tabs_list_item = render_to_string :partial => "workspace_tabs_list_item", :locals => {  :tabs_list_item_id => tabs_list_item_id,
                                                                                                :tabs_list_item_close_id => tabs_list_item_close_id,
                                                                                                :tab_content_id => tab_content_id,
                                                                                                :tab_name => "Portfolio collection: " + @portfolio_collection.collection.tag_line }
        tab_content_div = render_to_string :partial => "workspace_portfolio_collection_instance_tab_content_div",
                                               :locals => {  :tab_content_id => tab_content_id,
                                               :portfolio_collection => @portfolio_collection }

        render :update do |page|
            page.insert_html :bottom, 'organizer-workspace-tabs-list', tabs_list_item
            page.insert_html :bottom, 'organizer-workspace-body', tab_content_div
            page << "tabsControl.addTab( $( '#{ tabs_list_item_id}' ).down().down() )"
            page << "tabsControl.setActiveTab( $( '#{tabs_list_item_id}' ).down().down() )"
        end
    end

    def create_collection_form
        logger.debug "cm/organizer_controlloer/create_collection_form - inspecting  params:"
        logger.debug  params.inspect
        @archive = Archive.find params[:archive_id]
        @collection = Collection.new
        @collection.tag_line = "your tag line"
        @collection.description = "new collection"
        @image = Image.find params[:image_id]
        render :layout => false
    end

    def create_collection
        logger.debug "cm/organizer_controlloer/create_collection - inspecting  params:"
        logger.debug  params.inspect
        @archive = Archive.find params[:archive_id]
        @collection = Collection.new
        @collection.archive_id = @archive.id
        @collection.tag_line = params[:tag_line]
        @collection.description = params[:description]
        @image = Image.find params[:image_id]
        @collection.images << @image
        @collection.save
        response_body = render_to_string :partial => "workspace_collections_tab_content", :locals => { :archive => @archive, :initial_render => false }
        render :inline => response_body
    end

    def delete_collection_form
        @archive = Archive.find params[:archive_id]
        @collection = Collection.find params[:collection_id]
        render :layout => false
    end

    def delete_collection
        logger.debug "cm/organizer_controller/delete_collection - inspecting params:"
        logger.debug params.inspect
        @archive = Archive.find params[:archive_id]
        @collection = Collection.find params[:collection_id]
        @collection.destroy
        response_body = render_to_string :partial => "workspace_collections_tab_content", :locals => { :archive => @archive, :initial_render => false }
        render :inline => response_body
    end

    def create_portfolio_form
        logger.debug "cm/organizer_controlloer/create_portfolio_form - inspecting  params:"
        logger.debug  params.inspect
        @archive = Archive.find params[:archive_id]
        @portfolio = Portfolio.new
        @portfolio.description = "new collection"
        @image = Image.find params[:image_id]
        render :layout => false
    end

    def create_portfolio
        logger.debug "cm/organizer_controlloer/create_portfolio - inspecting  params:"
        logger.debug  params.inspect

        @archive = Archive.find params[:archive_id]

        portfolio = Portfolio.create( :archive_id => @archive.id,
                                      :description => params[:description] )

        logger.debug "cm/organizer_controller/create_portfolio - created portfolio:"
        logger.debug portfolio.inspect

        image = Image.find params[:image_id]
        collection = image.collections[0]

        portfolio_collection = PortfolioCollection.create( :portfolio => portfolio,
                                                           :collection => collection,
                                                           :show_seq => 1 )

        portfolio.portfolio_collections << portfolio_collection

        image_show_view = ImageShowView.new
        image_show_view.image = image
        image_show_view.portfolio_collection = portfolio_collection
        image_show_view.show_seq = 1

        image.image_variants.each do |iv|
            if iv.is_web_default
                image_show_view.show_variant_id = iv.id
            end
            if iv.is_thumbnail_default
                image_show_view.thumbnail_variant_id = iv.id
            end
        end

        image_show_view.save

        portfolio_collection.default_show_view_id = image_show_view.id
        portfolio.default_show_view_id = image_show_view.id

        portfolio_collection.save
        portfolio.save

        response_body = render_to_string :partial => "workspace_portfolios_tab_content", :locals => { :archive => @archive, :initial_render => false }
        render :inline => response_body
    end

    def delete_portfolio_form
        @archive = Archive.find params[:archive_id]
        @portfolio = Portfolio.find params[:portfolio_id]
        render :layout => false
    end

    def delete_portfolio
        logger.debug "cm/organizer_controller/delete_portfolio - inspecting params:"
        logger.debug params.inspect
        @archive = Archive.find params[:archive_id]
        @portfolio = Portfolio.find params[:portfolio_id]
        @portfolio.destroy
        response_body = render_to_string :partial => "workspace_portfolios_tab_content", :locals => { :archive => @archive, :initial_render => false }
        render :inline => response_body
    end

    def create_portfolio_collection_form
        logger.debug "cm/organizer_controlloer/create_portfolio_collection_form - inspecting  params:"
        logger.debug  params.inspect
        @archive = Archive.find params[:archive_id]
        @portfolio = Portfolio.find params[:portfolio_id]
        @image = Image.find params[:image_id]
        @collections = []
        @archive.collections.each do |collection|
            if collection.images.include? @image
                @collections.push( collection )
            end
        end
        @tab_content_id = params[:tab_content_id]
        render :layout => false
    end

    def create_portfolio_collection
        logger.debug "cm/organizer_controlloer/create_portfolio_collection - inspecting  params:"
        logger.debug  params.inspect
        @archive = Archive.find params[:archive_id]
        @portfolio = Portfolio.find params[:portfolio_id]
        @collection = Collection.find params[:selected_collection_id]
        @image = Image.find params[:image_id]

        portfolio_collection = PortfolioCollection.create( :portfolio => @portfolio,
                                                           :collection => @collection,
                                                           :show_seq => @portfolio.portfolio_collections.length+1 )

        @portfolio.portfolio_collections << portfolio_collection

        image_show_view = ImageShowView.new
        image_show_view.image = @image
        image_show_view.portfolio_collection = portfolio_collection
        image_show_view.show_seq = 1

        @image.image_variants.each do |iv|
            if iv.is_web_default
                image_show_view.show_variant_id = iv.id
            end
            if iv.is_thumbnail_default
                image_show_view.thumbnail_variant_id = iv.id
            end
        end

        image_show_view.save

        portfolio_collection.default_show_view_id = image_show_view.id
        if not @portfolio.default_show_view_id
            @portfolio.default_show_view_id = image_show_view.id
        end

        portfolio_collection.save
        @portfolio.save

        response_body = render_to_string :partial => "workspace_portfolio_instance_tab_content_div",
                                         :locals => { :archive => @archive,
                                                      :portfolio => @portfolio,
                                                      :initial_render => false,
                                                      :tab_content_id => params[:tab_content_id] }
        render :inline => response_body
    end

    def delete_portfolio_collection_form
        logger.debug "cm/organizer_controller/delete_portfolio_collection_form - inspecting params:"
        logger.debug params.inspect
        @archive = Archive.find params[:archive_id]
        @portfolio_collection = PortfolioCollection.find params[:portfolio_collection_id]
        @tab_content_id = params[:tab_content_id]
        render :layout => false
    end

    def delete_portfolio_collection
        logger.debug "cm/organizer_controller/delete_portfolio_collection - inspecting params:"
        logger.debug params.inspect
        @archive = Archive.find params[:archive_id]
        @portfolio_collection = PortfolioCollection.find params[:portfolio_collection_id]
        @portfolio = @portfolio_collection.portfolio
        @portfolio_collection.destroy
        response_body = render_to_string :partial => "workspace_portfolio_instance_tab_content_div",
                                         :locals => { :archive => @archive,
                                                      :portfolio => @portfolio,
                                                      :initial_render => false,
                                                      :tab_content_id => params[:tab_content_id] }
        render :inline => response_body
    end

end
