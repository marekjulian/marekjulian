class Cm::OrganizerController < ApplicationController

    include ImageAndVariants

    before_filter :login_required

    skip_before_filter :verify_authenticity_token,
                       :only => [:create_collection_form,
                                 :delete_collection_form,
                                 :create_portfolio_form,
                                 :delete_portfolio_form,
                                 :create_portfolio_collection_form,
                                 :delete_portfolio_collection_form,
                                 :create_portfolio_collection,
                                 :delete_portfolio_collection]

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
        logger.debug "update_preview_content_for_collections_tab: params - "
        logger.debug params.inspect
        @archive = Archive.find( params[:archive_id] )
        if params['selected-collection-id'] == 'all'
            images = @archive.images
        elsif params['selected-collection-id'] == 'prompt'
            images = nil
        elsif params['selected-collection-id']
            collection = Collection.find( params['selected-collection-id'] )
            images = collection.images
        else
            images = nil
        end
        render :update do |page|
            page.replace_html 'organizer-preview-content-for-collections-tab', :partial => 'preview_content_for_collections_tab', :locals => { :images => images }
        end
    end

    def update_preview_content_for_portfolios_tab
        logger.debug "update_preview_content_for_portfolios_tab: params - "
        logger.debug params.inspect
        @archive = Archive.find( params[:archive_id] )
        if params['selected-collection-id'] == 'all'
            images = @archive.images
        elsif params['selected-collection-id'] == 'prompt'
            images = nil
        elsif params['selected-collection-id']
            collection = Collection.find( params['selected-collection-id'] )
            images = collection.images
        else
            images = nil
        end
        render :update do |page|
            page.replace_html 'organizer-preview-content-for-portfolios-tab', :partial => 'preview_content_for_portfolios_tab', :locals => { :images => images }
        end
    end

    def update_preview_content_for_collection_instance_tab
        logger.debug "update_preview_content_for_collection_instance_tab: params - "
        logger.debug params.inspect
        @archive = Archive.find( params[:archive_id] )
        tab_id = params[:tab_id]
        selected_collection_id = "organizer-preview-selected-collection-id-for-#{tab_id}-tab"
        collection_id = params[selected_collection_id]
        if collection_id == 'all'
            images = @archive.images
        else
            collection = Collection.find( collection_id )
            images = collection.images
        end
        render :update do |page|
            page.replace_html "organizer-preview-content-for-#{tab_id}-tab", :partial => 'preview_content_for_collection_instance_tab',
                                                                             :locals => { :images => images,
                                                                                          :tab_id => tab_id,
                                                                                          :collection_id => collection_id }
        end
    end

    def update_preview_content_for_portfolio_instance_tab
        logger.debug "update_preview_content_for_portfolio_instance_tab: params - "
        logger.debug params.inspect
        @archive = Archive.find( params[:archive_id] )
        @portfolio = Portfolio.find( params[:portfolio_id] )
        tab_id = params[:tab_id]
        selected_collection_id = "organizer-preview-selected-collection-id-for-#{tab_id}-tab"
        if params[selected_collection_id] == 'all'
            preview_collections = @archive.collections.select { |archive_collection| ! @portfolio.collections.include?(archive_collection) }
            preview_images = []
            preview_collections.each do |preview_collection|
                preview_images.concat( preview_collection.images )
            end
        elsif params[selected_collection_id] == 'prompt'
            preview_images = nil
        elsif params[selected_collection_id]
            collection = Collection.find( params[selected_collection_id] )
            preview_images = collection.images
        else
            preview_images = nil
        end
        render :update do |page|
            page.replace_html "organizer-preview-content-for-#{tab_id}-tab", :partial => 'preview_content_for_portfolio_instance_tab',
                                                                             :locals => { :images => preview_images,
                                                                                          :tab_id => tab_id }
        end
    end

    def update_preview_content_for_portfolio_collection_instance_tab
        render :update do |page|
        end
    end

    def create_new_collection_instance_tab
        logger.debug "cm/organizer_controller/create_new_collection_instance_tab - inspecting params:"
        logger.debug params.inspect

        @archive = Archive.find params[:archive_id]
        @collection = Collection.find params[:collection_id]

        tab_id = "t#{params[:next_tab_id]}"

        preview_div_id = "organizer-preview-t#{params[:next_tab_id]}-tab"
        preview_div = render_to_string :partial => "preview_for_collection_instance_tab",
                                       :locals => { :archive => @archive,
                                                    :preview_div_id => preview_div_id,
                                                    :tab_id => tab_id }
        tabs_list_item_id = "organizer-workspace-body-collection-" + params[:collection_id] + "-tab"
        tabs_list_item_close_id = "organizer-workspace-body-collection-" + params[:collection_id] + "-close"
        tabs_list_item_link_id = "organizer-workspace-body-#{tab_id}-tab-link"
        tab_content_id = "organizer-workspace-body-collection-" + params[:collection_id]
        tabs_list_item = render_to_string :partial => "workspace_tabs_list_item",
                                          :locals => { :tabs_list_item_id => tabs_list_item_id,
                                                       :tabs_list_item_close_id => tabs_list_item_close_id,
                                                       :tabs_list_item_link_id => tabs_list_item_link_id,
                                                       :tab_content_id => tab_content_id,
                                                       :tab_name => "Collection: " + @collection.tag_line }
        tab_content_div = render_to_string :partial => "workspace_collection_instance_tab_content_div",
                                           :locals => { :tab_content_id => tab_content_id,
                                                        :collection => @collection,
                                                        :tab_id => tab_id }

        render :update do |page|
            page.insert_html :bottom, 'organizer-preview', preview_div
            page.insert_html :bottom, 'organizer-workspace-tabs-list', tabs_list_item
            page.insert_html :bottom, 'organizer-workspace-body', tab_content_div
            page << "CM_ORGANIZER.previewControl.addPreview( $('#{tabs_list_item_link_id}'), '#{preview_div_id}' )"
            add_image_url = url_for( :controller => 'cm/organizer',
                                     :archive_id => params[:archive_id],
                                     :action => :add_image_to_collection,
                                     :collection_id => @collection.id,
                                     :tab_id => tab_id )
            page << "CM_ORGANIZER.workspaceControl.addTab( '#{tab_id}', 'collection', '#{params[:collection_id]}', '#{add_image_url}' )"
            page << "tabsControl.addTab( $('#{tabs_list_item_id}').down().down() )"
            page << "tabsControl.setActiveTab( $('#{tabs_list_item_id}' ).down().down() )"
        end
    end

    def create_new_collection_image_instance_tab
        logger.debug "cm/organizer_controller/create_new_collection_image_instance_tab"
        logger.debug params.inspect

        @archive = Archive.find params[:archive_id]
        @collection = Collection.find params[:collection_id]
        @image = Image.find params[:image_id]

        tab_id = "t#{params[:next_tab_id]}"

        preview_div_id = "organizer-preview-t#{params[:next_tab_id]}-tab"
        preview_div = render_to_string :partial => "preview_for_collection_image_instance_tab",
                                       :locals => { :preview_div_id => preview_div_id,
                                                    :tab_id => tab_id }

        tabs_list_item_id = "organizer-workspace-body-collection-image-" + params[:collection_id] + "-" + params[:image_id] + "-tab"
        tabs_list_item_close_id = "organizer-workspace-body-collection-image-" + params[:collection_id] + "-" + params[:image_id] + "-close"
        tabs_list_item_link_id = "organizer-workspace-body-#{tab_id}-tab-link"
        tab_content_id = "organizer-workspace-body-collection-image-" + params[:collection_id] + "-" + params[:image_id]
        tab_name = "Unnamed Image"
        @image.image_variants.each do |iv|
            if iv.is_master
                tab_name = iv.file_file_name
            end
        end
        tabs_list_item = render_to_string :partial => "workspace_tabs_list_item",
                                          :locals => {  :tabs_list_item_id => tabs_list_item_id,
                                                        :tabs_list_item_close_id => tabs_list_item_close_id,
                                                        :tabs_list_item_link_id => tabs_list_item_link_id,
                                                        :tab_content_id => tab_content_id,
                                                        :tab_name => tab_name }

        tab_content_div = render_to_string :partial => "workspace_collection_image_instance_tab_content_div",
                                           :locals => { :collection => @collection,
                                                        :image => @image,
                                                        :tab_content_id => tab_content_id,
                                                        :tab_id => tab_id }

        render :update do |page|
            page.insert_html :bottom, 'organizer-preview', preview_div
            page.insert_html :bottom, 'organizer-workspace-tabs-list', tabs_list_item
            page.insert_html :bottom, 'organizer-workspace-body', tab_content_div
            page << "CM_ORGANIZER.previewControl.addPreview( $('#{tabs_list_item_link_id}'), '#{preview_div_id}' )"
            add_image_variant_url = url_for( :controller => 'cm/organizer',
                                             :archive_id => params[:archive_id],
                                             :action => :add_image_variant_to_collection_image,
                                             :collection_id => @collection.id,
                                             :image_id => @image.id,
                                             :tab_id => tab_id )
            page << "CM_ORGANIZER.workspaceControl.addTab( '#{tab_id}', 'collection-image', '#{params[:collection_id]}', '#{params[:image_id]}', '#{add_image_variant_url}' )"
            page << "tabsControl.addTab( $('#{tabs_list_item_id}').down().down() )"
            page << "tabsControl.setActiveTab( $('#{tabs_list_item_id}' ).down().down() )"
        end
    end

    def create_new_portfolio_instance_tab
        logger.debug "cm/organizer_controller/create_new_portfolio_instance_tab"
        logger.debug params.inspect

        @archive = Archive.find params[:archive_id]
        @portfolio = Portfolio.find params[:portfolio_id]

        tab_id = "t#{params[:next_tab_id]}"

        preview_div_id = "organizer-preview-t#{params[:next_tab_id]}-tab"
        preview_div = render_to_string :partial => "preview_for_portfolio_instance_tab",
                                       :locals => { :archive => @archive,
                                                    :portfolio => @portfolio,
                                                    :preview_div_id => preview_div_id,
                                                    :tab_id => "t#{params[:next_tab_id]}" }
        tabs_list_item_id = "organizer-workspace-body-portfolio-" + params[:portfolio_id] + "-tab"
        tabs_list_item_close_id = "organizer-workspace-body-portfolio-" + params[:portfolio_id] + "-close"
        tabs_list_item_link_id = "organizer-workspace-body-t#{params[:next_tab_id]}-tab-link"
        tab_content_id = "organizer-workspace-body-portfolio-" + params[:portfolio_id]
        tabs_list_item = render_to_string :partial => "workspace_tabs_list_item", :locals => {  :tabs_list_item_id => tabs_list_item_id,
                                                                                                :tabs_list_item_close_id => tabs_list_item_close_id,
                                                                                                :tabs_list_item_link_id => tabs_list_item_link_id,
                                                                                                :tab_content_id => tab_content_id,
                                                                                                :tab_name => "Portfolio: " + @portfolio.description }
        tab_content_div = render_to_string :partial => "workspace_portfolio_instance_tab_content_div",
                                           :locals => { :archive => @archive,
                                                        :portfolio => @portfolio,
                                                        :tab_content_id => tab_content_id,
                                                        :tab_id => tab_id }

        render :update do |page|
            page.insert_html :bottom, 'organizer-preview', preview_div
            page.insert_html :bottom, 'organizer-workspace-tabs-list', tabs_list_item
            page.insert_html :bottom, 'organizer-workspace-body', tab_content_div
            page << "CM_ORGANIZER.previewControl.addPreview( $('#{tabs_list_item_link_id}'), '#{preview_div_id}')"
            replace_default_show_view_url = url_for( :controller => 'cm/organizer',
                                                     :archive_id => params[:archive_id],
                                                     :action => :replace_default_show_view_for_portfolio,
                                                     :portfolio_id => @portfolio.id,
                                                     :tab_id => tab_id )
            page << "CM_ORGANIZER.workspaceControl.addTab( '#{tab_id}', 'portfolio', '#{params[:portfolio_id]}', '#{replace_default_show_view_url}' )"
            image_area_id = "organizer-workspace-body-portfolio-instance-image-area-#{tab_id}"
            page << "CM_ORGANIZER.workspaceControl.addDroppable( '#{tab_id}', '#{image_area_id}' )"
            page << "CM_ORGANIZER.workspaceControl.getTabControl( '#{tab_id}' ).createSortable()"
            page << "tabsControl.addTab( $('#{ tabs_list_item_id}').down().down() )"
            page << "tabsControl.setActiveTab( $('#{tabs_list_item_id}' ).down().down() )"
        end
    end

    def create_new_portfolio_collection_instance_tab
        logger.debug "cm/organizer_controller/create_new_portfolio_collection_instance_tab - inspecting params:"
        logger.debug params.inspect

        @archive = Archive.find params[:archive_id]
        @portfolio_collection = PortfolioCollection.find params[:portfolio_collection_id]

        tab_id = "t#{params[:next_tab_id]}"

        preview_div_id = "organizer-preview-#{tab_id}-tab"
        preview_div = render_to_string :partial => "preview_for_portfolio_collection_instance_tab",
                                       :locals => { :portfolio_collection => @portfolio_collection,
                                                    :preview_div_id => preview_div_id,
                                                    :tab_id => tab_id }
        tabs_list_item_id = "organizer-workspace-body-portfolio-collection-" + params[:portfolio_collection_id] + "-tab"
        tabs_list_item_close_id = "organizer-workspace-body-portfolio-collection-" + params[:portfolio_collection_id] + "-close"
        tabs_list_item_link_id = "organizer-workspace-body-#{tab_id}-tab-link"
        tab_content_id = "organizer-workspace-body-portfolio-collection-" + params[:portfolio_collection_id]
        tabs_list_item = render_to_string :partial => "workspace_tabs_list_item", :locals => {  :tabs_list_item_id => tabs_list_item_id,
                                                                                                :tabs_list_item_close_id => tabs_list_item_close_id,
                                                                                                :tabs_list_item_link_id => tabs_list_item_link_id,
                                                                                                :tab_content_id => tab_content_id,
                                                                                                :tab_name => "Portfolio collection: " + @portfolio_collection.collection.tag_line }
        tab_content_div = render_to_string :partial => "workspace_portfolio_collection_instance_tab_content_div",
                                           :locals => {  :tab_content_id => tab_content_id,
                                                         :portfolio_collection => @portfolio_collection,
                                                         :tab_id => tab_id }

        render :update do |page|
            page.insert_html :bottom, 'organizer-preview', preview_div
            page.insert_html :bottom, 'organizer-workspace-tabs-list', tabs_list_item
            page.insert_html :bottom, 'organizer-workspace-body', tab_content_div
            page << "CM_ORGANIZER.previewControl.addPreview( $('#{tabs_list_item_link_id}'), '#{preview_div_id}' )"
            preview_content_div_id = "organizer-preview-content-for-#{tab_id}-tab"
            add_preview_image_url = url_for( :controller => 'cm/organizer',
                                             :archive_id => params[:archive_id],
                                             :action => :add_image_to_portfolio_collection_preview,
                                             :portfolio_collection_id => @portfolio_collection.id,
                                             :tab_id => tab_id,
                                             :preview_container_id => preview_content_div_id )
            replace_default_show_view_url = url_for( :controller => 'cm/organizer',
                                                     :archive_id => params[:archive_id],
                                                     :action => :replace_default_show_view_for_portfolio_collection,
                                                     :portfolio_collection_id => @portfolio_collection.id,
                                                     :tab_id => tab_id )
            add_image_url = url_for( :controller => 'cm/organizer',
                                     :archive_id => params[:archive_id],
                                     :action => :add_image_to_portfolio_collection,
                                     :portfolio_collection_id => @portfolio_collection.id,
                                     :tab_id => tab_id )
            add_image_show_view_url = url_for( :controller => 'cm/organizer',
                                               :archive_id => params[:archive_id],
                                               :action => :add_image_show_view_to_portfolio_collection,
                                               :portfolio_collection_id => @portfolio_collection.id,
                                               :tab_id => tab_id )
            page << "CM_ORGANIZER.workspaceControl.addTab( '#{tab_id}', 'portfolio-collection', '#{params[:portfolio_collection_id]}', '#{add_preview_image_url}', '#{replace_default_show_view_url}', '#{add_image_url}', '#{add_image_show_view_url}' )"
            page << "tabsControl.addTab( $( '#{ tabs_list_item_id}' ).down().down() )"
            page << "tabsControl.setActiveTab( $( '#{tabs_list_item_id}' ).down().down() )"
        end
    end

    def reload_collection_instance_tab
        @archive = Archive.find( params[:archive_id] )
        @collection = Collection.find( params[:collection_id] )
        tab_id = params[:tab_id]
        preview_form_id = "organizer-preview-selection-form-for-#{tab_id}-tab"
        workspace_form_id = "organizer-workspace-body-form-#{tab_id}-#{@collection.id}"
        render :update do |page|
            page.replace_html preview_form_id, :partial => 'preview_for_collection_instance_tab_selected_tag',
                                               :locals => { :tab_id => tab_id,
                                                            :form_id =>  preview_form_id,
                                                            :archive => @archive }
            if @archive.images.count <= 20
                page.replace_html "organizer-preview-content-for-#{tab_id}-tab", :partial => 'preview_content_for_collection_instance_tab',
                                                                                 :locals => { :images => @archive.images,
                                                                                              :tab_id => tab_id,
                                                                                              :collection_id => 'all' }
            else
                page.replace_html "organizer-preview-content-for-#{tab_id}-tab", ""
            end
            page << "$( '#{workspace_form_id}-tag-line' ).value = '#{@collection.tag_line}';"
            page << "$( '#{workspace_form_id}-description' ).value = '#{@collection.description}';"
            image_area_list_id = "organizer-workspace-body-collection-image-instance-list-#{tab_id}-#{@collection.id}"
            page.replace_html image_area_list_id, :partial => "workspace_collection_instance_image_area_list",
                                                  :locals => { :tab_id => tab_id,
                                                               :collection => @collection }
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
        @tab_id = params[:tab_id]
        @tab_content_id = params[:tab_content_id]
        @image_area_container_id = params[:image_area_container_id]
        render :layout => false
    end

    def create_portfolio_collection
        logger.debug "cm/organizer_controlloer/create_portfolio_collection - inspecting  params:"
        logger.debug  params.inspect
        @archive = Archive.find params[:archive_id]
        @portfolio = Portfolio.find params[:portfolio_id]
        @collection = Collection.find params[:selected_collection_id]
        @image = Image.find params[:image_id]
        tab_id = params[:tab_id]

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

        form_id = "organizer-preview-selection-form-for-#{tab_id}-tab"
        preview_collections = @archive.collections.select { |archive_collection| ! @portfolio.collections.include?(archive_collection) }

        #
        # A little bit of a missnomer, but the contest of the list are generated (all the list items).
        #
        image_area_list = render_to_string :partial => "workspace_portfolio_instance_image_area_list",
                                           :locals => { :portfolio => @portfolio,
                                                        :tab_id => tab_id,
                                                        :tab_content_id => params[:tab_content_id],
                                                        :image_area_container_id => params[:image_area_container_id] }

        render :update do |page|
            page.replace "organizer-preview-selected-collection-id-for-#{tab_id}-tab",
                         :partial => 'preview_for_portfolio_instance_tab_selected_tag',
                         :locals => { :tab_id => tab_id,
                                      :form_id => form_id,
                                      :archive => @archive,
                                      :portfolio => @portfolio,
                                      :preview_collections => preview_collections }
            page.replace_html "organizer-preview-content-for-#{tab_id}-tab", :partial => 'preview_content_for_portfolio_instance_tab',
                                                                             :locals => { :images => nil,
                                                                                          :tab_id => tab_id }
            page.replace_html( params[:image_area_container_id], image_area_list )
            page.insert_html :after,
                             params[:image_area_container_id],
                             "<script>CM_ORGANIZER.workspaceControl.getTabControl( '#{params[:tab_id]}' ).createSortable();</script>"
        end
    end

    def delete_portfolio_collection_form
        #
        # Generate a form to delete a portfolio collection inside a portfolio instance tab.
        #
        # params:
        #   :archive_id
        #   :portfolio_collection_id
        #   :tab_id
        #   :tab_content_id
        #   :image_area_container_id
        #
        logger.debug "cm/organizer_controller/delete_portfolio_collection_form - inspecting params:"
        logger.debug params.inspect
        @archive = Archive.find params[:archive_id]
        @portfolio_collection = PortfolioCollection.find params[:portfolio_collection_id]
        @tab_id = params[:tab_id]
        @tab_content_id = params[:tab_content_id]
        @image_area_container_id = params[:image_area_container_id]
        render :layout => false
    end

    def delete_portfolio_collection
        #
        # Delete a portfolio_collection in a portfolio instance tab.
        #
        # params:
        #   :portfolio_collection_id
        #   :tab_id
        #   :tab_content_id
        #   :image_area_container_id
        #
        logger.debug "cm/organizer_controller/delete_portfolio_collection - inspecting params:"
        logger.debug params.inspect
        @archive = Archive.find params[:archive_id]
        @portfolio_collection = PortfolioCollection.find params[:portfolio_collection_id]
        @portfolio = @portfolio_collection.portfolio
        @portfolio_collection.destroy
        @portfolio.save

        tab_id = params[:tab_id]

        form_id = "organizer-preview-selection-form-for-#{tab_id}-tab"
        preview_collections = @archive.collections.select { |archive_collection| ! @portfolio.collections.include?(archive_collection) }

        #
        # A little bit of a missnomer, but the contest of the list are generated (all the list items).
        #
        image_area_list = render_to_string :partial => "workspace_portfolio_instance_image_area_list",
                                           :locals => { :portfolio => @portfolio,
                                                        :tab_id => tab_id,
                                                        :tab_content_id => params[:tab_content_id],
                                                        :image_area_container_id => params[:image_area_container_id] }

        render :update do |page|
            page.replace "organizer-preview-selected-collection-id-for-#{tab_id}-tab",
                         :partial => 'preview_for_portfolio_instance_tab_selected_tag',
                         :locals => { :tab_id => tab_id,
                                      :form_id => form_id,
                                      :archive => @archive,
                                      :portfolio => @portfolio,
                                      :preview_collections => preview_collections }
            page.replace_html "organizer-preview-content-for-#{tab_id}-tab", :partial => 'preview_content_for_portfolio_instance_tab',
                                                                             :locals => { :images => nil,
                                                                                          :tab_id => tab_id }
            page.replace_html( params[:image_area_container_id], image_area_list )
            page.insert_html :after,
                             params[:image_area_container_id],
                             "<script>CM_ORGANIZER.workspaceControl.getTabControl( '#{params[:tab_id]}' ).createSortable();</script>"
        end
    end

    def add_image_to_collection
        logger.debug "cm/organizer_controller/add_image_to_collection"
        logger.debug params.inspect

        @archive = Archive.find params[:archive_id]
        @collection = Collection.find params[:collection_id]
        @image = Image.find params[:image_id]

        image_area_item = render_to_string :partial => "workspace_image_in_collection",
                                           :locals => { :collection => @collection,
                                                        :image => @image,
                                                        :tab_id => params[:tab_id] }

        render :update do |page|
            page.insert_html :bottom, params[:image_area_container_id], image_area_item
        end
    end

    def add_image_variant_to_collection_image
        logger.debug "cm/organizer_controller/add_image_variant_to_collection_image"
        logger.debug params.inspect

        @archive = Archive.find params[:archive_id]
        @collection = Collection.find params[:collection_id]
        @image = Image.find params[:image_id]
        @image_variant = ImageVariant.find params[:image_variant_id]

        image_area_list_item = render_to_string :partial => "workspace_collection_image_iv_li",
                                                :locals => { :collection => @collection,
                                                             :image => @image,
                                                             :image_variant => @image_variant,
                                                             :tab_id => params[:tab_id] }

        render :update do |page|
            image_area_list_id = "organizer-workspace-body-collection-image-instance-list-" + params[:collection_id] + "-" + params[:image_id]

            page.insert_html :bottom, image_area_list_id, image_area_list_item
        end
    end

    def replace_default_show_view_for_portfolio
        logger.debug "cm/organizer_controller/replace_default_show_view_in_portfolio"
        logger.debug params.inspect

        image_tag = ""
        portfolio_collection = PortfolioCollection.find params[:portfolio_collection_id]
        if portfolio_collection
            image_tag = render_to_string :partial => "workspace_portfolio_default_show_view",
                                         :locals => { :portfolio_collection => portfolio_collection,
                                                      :image_tag_id => "" }
        end

        render :update do |page|
            container_id = params[:image_area_container_id]
            page.replace_html( container_id, image_tag )
        end
    end

    def replace_default_show_view_for_portfolio_collection
        logger.debug "cm/organizer_controller/replace_default_show_view_in_portfolio_collection"
        logger.debug params.inspect

        image_tag = ""

        if params[:image_show_view_id]
            image_show_view = ImageShowView.find params[:image_show_view_id]
            image_tag = render_to_string :partial => "workspace_portfolio_collection_default_show_view",
                                         :locals => { :image_show_view => image_show_view,
                                                      :image_tag_id => "" }
        elsif params[:image_id]
            image = Image.find params[:image_id]
            image_tag = render_to_string :partial => "workspace_portfolio_collection_image",
                                         :locals => { :image => image,
                                                      :image_tag_id => "" }
        end

        logger.debug "cm/organizer_controller/replace_default_show_view_in_portfolio_collection - image tag: " + image_tag

        render :update do |page|
            container_id = params[:image_area_container_id]
            page.replace_html( container_id, image_tag )
        end
    end

    def add_image_to_portfolio_collection_preview
        if params[:image_id]
            image = Image.find params[:image_id]
        elsif params[:image_show_view_id]
            image_show_view = ImageShowView.find params[:image_show_view_id]
            image = image_show_view.image
        end


        preview_item = render_to_string :partial => "preview_image_for_portfolio_collection_instance_tab",
                                        :locals => { :tab_id => params[:tab_id],
                                                     :image => image }
        render :update do |page|
            page.insert_html :bottom, params[:preview_container_id], preview_item
        end
    end

    def add_image_to_portfolio_collection
        @archive = Archive.find params[:archive_id]
        @image = Image.find params[:image_id]
        change_id = params[:change_id]

        image_area_item = render_to_string :partial => "workspace_add_image_to_portfolio_collection",
                                           :locals => { :image => @image,
                                                        :tab_id => params[:tab_id],
                                                        :change_id => change_id,
                                                        :image_area_list_id => params[:image_area_container_id],
                                                        :form_id => params[:form_id] }

        render :update do |page|
            page.insert_html :bottom, params[:image_area_container_id], image_area_item
        end
    end

    def add_image_show_view_to_portfolio_collection
        @portfolio_collection = PortfolioCollection.find params[:portfolio_collection_id]
        @image_show_view = ImageShowView.find params[:image_show_view_id]

        image_area_item = render_to_string :partial => "workspace_add_image_show_view_to_portfolio_collection",
                                           :locals => { :tab_id => params[:tab_id],
                                                        :portfolio_collection => @portfolio_collection,
                                                        :image_show_view =>  @image_show_view,
                                                        :image_area_list_id => params[:image_area_container_id],
                                                        :form_id => params[:form_id] }
        render :update do |page|
            page.insert_html :bottom, params[:image_area_container_id], image_area_item
        end
    end

    def workspace_save_collection
        #
        #   Description: Process of a save of 'collection' instance tab. The payload MUST be json, as well as the response. A saple
        #       payload is as follows:
        #
        #       {"commit"=>"Save",
        #        "authenticity_token"=>"+4HmK6g2j4VT++JXi5U171E4702FFTAKI8eitg3hhUo=",
        #        "archive_id"=>"1",
        #        "controller"=>"cm/organizer",
        #        "action"=>"workspace_save_collection",
        #        "collection_id" => <collection id of image in the workspace>,
        #        "tag_line" => <tag line>,
        #        "description"=> <descriptioni>,
        #        "changes"=>[{"change_type" => "add", "image_id"=>"267"}] }
        #
        #       The tab's focus is a particular collection which is opened in the workspace, as identified by "collection_id".
        #       "changes" contains a list of changes which were made by the user. Currently, the only changes supported are
        #       addition of an image to a collection.
        #
        logger.debug "cm/organizer_controller/workspace_save_collection"
        logger.debug params.inspect

        collection = Collection.find params[:collection_id]
        collection.tag_line = params[:tag_line]
        collection.description = params[:description]

        #
        # Process the items in params[:changes]
        #
        params[:changes].each do |change|
            if change["change_type"] == "add"
                image = Image.find change["image_id"]
                if image
                    collection.images << image
                end
            end
        end

        collection.save

        response = {  'status' => '0' }
        render :json => response
    end

    def workspace_save_portfolio
        logger.debug "cm/organizer_controller/workspace_save_collection"
        logger.debug params.inspect

        portfolio = Portfolio.find params["portfolio_id"]

        portfolio.description = params[:description]

        show_seq = 0
        params[:sortables].split('&').each do |image|
            id = image.split('=')[1]
            id_parts = id.split('-')
            portfolio_collection_id = id_parts[-1]
            pc = PortfolioCollection.find portfolio_collection_id
            pc.show_seq = show_seq
            pc.save
            show_seq = show_seq + 1
        end

        if params[:default_portfolio_collection_id]
            default_portfolio_collection = PortfolioCollection.find params[:default_portfolio_collection_id]
            if default_portfolio_collection
                portfolio.default_show_view_id = default_portfolio_collection.default_show_view_id
            end
        end

        portfolio.save

        response = {  'status' => '0' }
        render :json => response
    end

    def workspace_save_collection_image
        #
        #   Description: Processes a save of a 'collection image' intance tab. The payload MUST be json, as well as the response. A sample
        #       payload is as follows:
        #
        #       {"commit"=>"Save",
        #        "authenticity_token"=>"+4HmK6g2j4VT++JXi5U171E4702FFTAKI8eitg3hhUo=",
        #        "archive_id"=>"1",
        #        "controller"=>"cm/organizer",
        #        "action"=>"workspace_save_collection_image",
        #        "collection_id" => <collection id of image in the workspace>,
        #        "image_id" => <the image id of the image in the workspace>,
        #        "description"=>"chair",
        #        "changes"=>[{"from_image_id"=>"268", "image_variant_id"=>"435", "to_image_id"=>"267"}] }
        #
        #       The tab's focus is a particular image which is opened in the workspace, as identified by "collection_id" and
        #       "image_id". "changes" contains a list of changes which were made by the user, this is either image_variants
        #       being removed or added to the image opened in the workspace.
        #
        logger.debug "cm/organizer_controller/workspace_save_collection_image"
        logger.debug params.inspect

        image = Image.find params[:image_id]
        image.description = params[:description]

        #
        # Other images which are affected as image_variants are either moved to them, or removed from them.
        # If an image results in have NO image_variants, it is destroyed.
        #
        other_affected_images = { }

        #
        # Process the items in params[:changes]
        #
        params[:changes].each do |change|
            from_image = Image.find change["from_image_id"]
            to_image = Image.find change["to_image_id"]
            iv = ImageVariant.find change["image_variant_id"]
            logger.debug "cm/organizer_controller/workspace_save_collection_image - bucket = " + iv.file.bucket_name + ", key = " + iv.file.path
            if from_image and to_image and iv
                if from_image.id != image.id
                    if iv.is_master
                        from_image.master_variant_id = nil
                        iv.is_master = false
                    end
                    if iv.is_web_default
                        from_image.web_default_variant_id = nil
                        iv.is_web_default = false
                    end
                    if iv.is_thumbnail_default
                        from_image.thumbnail_default_variant_id = nil
                        iv.is_thumbnail_default = false
                    end
                    other_affected_images[ from_image.id ] = from_image
                end
                if to_image.id != image.id
                    other_affected_iamges[ to_image.id ] = to_image
                end
                #
                # key is like the following: 1/images/272/original/157_200305_30_350x500.jpg
                #
                original_from_key = iv.file.path( :original )
                if original_from_key
                    iv.file.s3_bucket.key( original_from_key ).grantees().each do |grantee|
                        logger.debug "cm/organizer_controller/workspace_save_collection_image - original from grantee, name = #{grantee.name}, id = #{grantee.id}"
                        grantee.perms.each do |perm|
                            logger.debug "    has perm: #{perm}}"
                        end
                    end
                    from_grantees = iv.file.s3_bucket.key( original_from_key ).grantees()
                    original_to_key = original_from_key.sub( "images/#{from_image.id}", "images/#{to_image.id}" )
                    logger.debug "cm/organizer_controller/workspace_save_collection_image - bucket = " + iv.file.bucket_name + ", from id = #{from_image.id}, to id = #{to_image.id}, moving from key = " + original_from_key + ", to key = " + original_to_key
                    new_key = iv.file.s3_bucket.rename_key( original_from_key, original_to_key )

                    aws_to_key = iv.file.s3_bucket.key( original_to_key )
                    RightAws::S3::Grantee.new( aws_to_key, 'http://acs.amazonaws.com/groups/global/AllUsers', 'READ', :apply, 'AllUsers' )

                    iv.file.s3_bucket.key( original_to_key ).grantees().each do |grantee|
                        logger.debug "cm/organizer_controller/workspace_save_collection_image - original to grantee, name = #{grantee.name}, id = #{grantee.id}"
                        grantee.perms.each do |perm|
                            logger.debug "    has perm: #{perm}}"
                        end
                    end
                end
                default_thumb_from_key = iv.file.path( :default_thumb )
                if default_thumb_from_key
                    default_thumb_to_key = default_thumb_from_key.sub( "images/#{from_image.id}", "images/#{to_image.id}" )
                    logger.debug "cm/organizer_controller/workspace_save_collection_image - bucket = " + iv.file.bucket_name + ", from id = #{from_image.id}, to id = #{to_image.id}, moving from key = " + default_thumb_from_key + ", to key = " + default_thumb_to_key
                    new_key = iv.file.s3_bucket.rename_key( default_thumb_from_key, default_thumb_to_key )

                    aws_to_key = iv.file.s3_bucket.key( default_thumb_to_key )
                    RightAws::S3::Grantee.new( aws_to_key, 'http://acs.amazonaws.com/groups/global/AllUsers', 'READ', :apply, 'AllUsers' )
                end
                web_from_key = iv.file.path( :web )
                if web_from_key
                    web_to_key = web_from_key.sub( "images/#{from_image.id}", "images/#{to_image.id}" )
                    logger.debug "cm/organizer_controller/workspace_save_collection_image - bucket = " + iv.file.bucket_name + ", from id = #{from_image.id}, to id = #{to_image.id}, moving from key = " + web_from_key + ", to key = " + web_to_key
                    new_key = iv.file.s3_bucket.rename_key( web_from_key, web_to_key )

                    aws_to_key = iv.file.s3_bucket.key( web_to_key )
                    RightAws::S3::Grantee.new( aws_to_key, 'http://acs.amazonaws.com/groups/global/AllUsers', 'READ', :apply, 'AllUsers' )
                end
                to_image.image_variants << iv
            end
        end

        #
        # Save all the images... We delete an affected image if it has NO image_variants.
        # However, we never delete the image which is the focus of the tab.
        #
        image.image_variants.each do |iv|
            iv.attributes_mode = 'auto'
        end
        resolve_image_variants( image )
        image.save
        other_affected_images.each_value do |affected_image|
            if affected_image.image_variants.count > 0
                affected_image.image_variants.each do |iv|
                    iv.attributes_mode = 'auto'
                end
                resolve_image_variants( affected_image )
                affected_image.save
            else
                affected_image.destroy
            end
        end

        response = {  'status' => '0' }
        render :json => response
    end

    def workspace_save_portfolio_collection
        logger.debug "cm/organizer_controller/workspace_save_portfolio_collection"
        logger.debug params.inspect

        @portfolio_collection = PortfolioCollection.find params[:portfolio_collection_id]

        changed_image_show_views = { }

        initial_portfolio_default_show_view_id = @portfolio_collection.portfolio.default_show_view_id
        initial_portfolio_collection_default_show_view_id = @portfolio_collection.default_show_view_id

        params[:changes].each do |change|
            logger.debug "cm/organizer_controller/workspace_save_portfolio_collection - processing change..."

            if change["change_type"] == "add"
                image = Image.find change["image_id"]
                image_show_view = ImageShowView.new
                image_show_view.image = image
                image_show_view.portfolio_collection = @portfolio_collection
                image_show_view.show_seq = @portfolio_collection.image_show_views.count + 1
                image_show_view.show_variant_id = nil
                image_show_view.thumbnail_variant_id = nil
                image.image_variants.each do |iv|
                    if iv.is_web_default
                        image_show_view.show_variant_id = iv.id
                    end
                    if iv.is_thumbnail_default
                        image_show_view.thumbnail_variant_id = iv.id
                    elsif image_show_view.thumbnail_variant_id == nil and iv.is_thumbnail
                        image_show_view.thumbnail_variant_id = iv.id
                    end
                    if image_show_view.show_variant_id == nil
                        if iv.file.exists? :web
                            image_show_view.show_variant_id = iv.id
                        end
                    end
                    if image_show_view.thumbnail_variant_id == nil
                        if iv.file.exists? :default_thumb
                            image_show_view.thumbnail_variant_id = iv.id
                        end
                    end
                end
                @portfolio_collection.image_show_views << image_show_view
                image_show_view.save
                changed_image_show_views[change["change_id"].to_s] = image_show_view
            elsif change["change_type"] == "remove"
                image_show_view = ImageShowView.find change["image_show_view_id"]
                image_show_view.destroy
                changed_image_show_views[change["change_id"].to_s] = image_show_view
                if @portfolio_collection.default_show_view_id == image_show_view.id
                    @portfolio_collection.default_show_view_id = nil
                end
                portfolio = @portfolio_collection.portfolio
                if portfolio.default_show_view_id == image_show_view.id
                    portfolio.default_show_view_id = nil
                end
            end
        end

        #
        # Now, update the order of the image show views. We may get something like this from the client:
        #
        # "sortables"=>"images[]=org-work-img-show-view-li-t4-24-34-313&images[]=org-work-img-show-view-li-t4-24-32-312&images[]=org-work-added-img-li-t4-0-311"
        #
        # 1. create a hash of image_show_views, image_show_view_hash: image_show_view_id -> image_show_view
        # 2. have hash of changed image_show_views, changed_image_show_views: change_id -> image_show_view
        # 3. scan images in params[:sortables], updating 'show_seq' in image_show_view
        #
        show_seq = 0
        image_show_views = { }
        @portfolio_collection.image_show_views.each do |iv|
            logger.debug "cm/organizer_controller/workspace_save_portfolio_collection - adding iv.id = #{iv.id} to image_show_views"
            image_show_views[iv.id.to_s] = iv
        end
        params[:sortables].split('&').each do |image|
            id = image.split('=')[1]
            id_parts = id.split('-')
            if id =~ /^org-work-img-show-view-li/
                #
                # have an existing image show view
                #
                image_show_view_id = id_parts[-2]
                logger.debug "cm/organizer_controller/workspace_save_portfolio_collection - update iv #{image_show_view_id}.show_seq = #{show_seq}..."
                iv = image_show_views[image_show_view_id]
                iv.show_seq = show_seq
                iv.save
            else
                #
                # must be an added image
                #
                change_id = id_parts[-2]
                iv = changed_image_show_views[change_id]
                iv.show_seq = show_seq
                iv.save
            end
            show_seq = show_seq + 1
        end

        #
        # if newDefaultShowView:
        #   if type(newDefaultShowView) == ExistingImageShowVIew: - set to existing image_show_view
        #   if type(newDefaultShowView) == AddImageRef: - set to ImageShowView.find changedImageShowViews[AddImageRef.changeId]
        #
        if params[:new_default_show_view]
            new_default = params[:new_default_show_view]
            logger.debug "cm/organizer_controller/workspace_save_portfolio_collection - new default"
            logger.debug new_default.inspect
            if new_default[:type] === 'image_show_view'
                @portfolio_collection.default_show_view_id = new_default[:image_show_view_id]
            elsif new_default[:type] === 'image'
                image_show_view = changed_image_show_views[new_default[:change_id]]
                @portfolio_collection.default_show_view_id = image_show_view.id
            end
        end

        if @portfolio_collection.default_show_view_id == nil
            @portfolio_collection.default_show_view_id = @portfolio_collection.image_show_views.first.id
        end

        @portfolio_collection.save
        if @portfolio_collection.portfolio.default_show_view_id != initial_portfolio_default_show_view_id
            @portfolio_collection.portfolio.save
        end

        @portfolio_collection.image_show_views.reload

        if @portfolio_collection.default_show_view_id != initial_portfolio_collection_default_show_view_id
            default_thumbnail = render_to_string :partial => "workspace_portfolio_collection_default_thumbnail",
                                                 :locals => { :portfolio_collection => @portfolio_collection }
        else
            default_thumbnail = nil
        end
        image_area_list = render_to_string :partial => "workspace_portfolio_collection_instance_image_area_list",
                                           :locals => { :tab_id => params[:tab_id],
                                                        :portfolio_collection => @portfolio_collection }
        render :update do |page|
            if default_thumbnail
                page.replace_html( "#{params[:form_id]}-show-view", default_thumbnail )
            end
            page.replace_html( params[:image_area_container_id], image_area_list )
            #
            # page.insert_html :bottom,
            # params[:image_area_container_id],
            # '<script>alert("Inserted new image area list!")</script>'
            #
            page.insert_html :after,
                             params[:image_area_container_id],
                             "<script>CM_ORGANIZER.workspaceControl.getTabControl( '#{params[:tab_id]}' ).createSortable();</script>"
        end
    end

end
