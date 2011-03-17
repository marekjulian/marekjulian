class Cm::UploadersController < ApplicationController

    before_filter :show_session
    #
    # Require login ONLY for show and NOT create to avoid a flash cookie bug.
    # Should get it to load the proper cookie.
    #
    before_filter :login_required, :only => [ :show ]
    skip_before_filter :verify_authenticity_token, :only => [:create]
    layout "cm/uploader"

    def show_session
        logger.debug "cm/uploaders/show_session - inspecting..."
        logger.debug session.inspect
    end

    def show
        logger.debug "cm/uploaders/show - session_id: #{request.session_options[:id]}"
        logger.debug session.inspect
        @archive = Archive.find( params[:archive_id] )
        @collection = Collection.find(params[:collection_id])

        logger.debug "Showing uploader!"
    end

    def create
        logger.debug "cm/uploaders/create - session_id: #{request.session_options[:id]}"
        logger.debug session.inspect
        logger.debug "Updating uploader!"
        logger.debug params.inspect
        @archive = Archive.find( params[:archive_id] )
        @collection = Collection.find(params[:collection_id])

        #
        # Lets create a new hash, which makes it look like the request came from a regular rails
        # upload...
        #
        # An actual one coming from rails looks like this:
        #
        #   Parameters: {"commit"=>"> Upload image variants",
        #                "description"=>" L1000159.jpg"},
        #                "archive_id"=>"1",
        #                "collection_id"=>"3",
        #                "authenticity_token"=>"CqqSVjZVlgIr9mKB4x4KjSxqsWAbBn5ipdA3BNSh/tY=",
        #                "ImageVariantPropMode"=>"You tell us...",
        #                "image" => { "image_variants_attributes"=> { "0"=> {"is_web_default"=>"1",
        #                                                             "is_thumbnail"=>"0",
        #                                                             "is_master"=>"1",
        #                                                             "is_thumbnail_default"=>"0",
        #                                                             "properties_mode"=>"user",
        #                                                             "file"=>#<File:/var/folders/V4/V4JcaXFsFKmV34DlZ-UtF++++TM/-Tmp-/RackMultipart20101205-13314-1b0wphj-0> } }
        #               }
        #
        # An actual one coming from flash looks like this:
        #
        #   Parameters: {"Upload"=>"Submit Query",
        #                "Filename"=>"L1000159.jpg",
        #                "archive_id"=>"1",
        #                "collection_id"=>"3",
        #                "authenticity_token"=>"Lx7XnwdOka6AQHYMyc+Fig9h0nuIwqziyj2WCCzrBE0=",
        #                "Filedata"=>#<File:/var/folders/V4/V4JcaXFsFKmV34DlZ-UtF++++TM/-Tmp-/RackMultipart20101204-10545-fcx921-0>}
        #
        fakeParamsHash = { :description => params[:Filename],
                           :image_variants_attributes => { 0 => { :update_type => "add_image_variant",
                                                                  :attributes_mode => "user",
                                                                  :is_web_default => "0",
                                                                  :is_thumbnail => "0",
                                                                  :is_master => "1",
                                                                  :is_thumbnail_default => "0",
                                                                  :file => params[:Filedata] } } }

        @image = Image.new( fakeParamsHash )

        if @image
            logger.info "cm/uploaders/create - Created new image, id = %d." % @image.id
            ok = @archive.images << @image
            if ok && @collection
                ok = @collection.images << @image
            end
            logger.info "cm/uploaders/create - Added image to archive and collection..."
            @image.image_variants.each do | iv |
                logger.info "cm/uploaders/create - Saving image variant, id = %d." % iv.id
                ok = iv.save if ok
                logger.info "cm/uploaders/create - Saved image variant, id = %d." % iv.id
            end
            logger.info "cm/uploaders/create - Saving image, id = %d." % @image.id
            ok = @image.save if ok
            logger.info "cm/uploaders/create - Saved image, id = #{@image.id}, status = #{ok}."
        else
            logger.info "cm/uploaders/create - Failed to create new image."
            ok = false
        end

        respond_to do |format|
            format.json {
                if ok
                    response = { 'status' => '0' }
                else
                    response = { 'status' => '1' }
                end
                render :json => response
            }
        end
    end
end
