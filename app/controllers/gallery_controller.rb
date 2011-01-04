class GalleryController < ApplicationController

    before_filter :login_required
    before_filter :load_params

    layout "gallery"

    def show

        if @collection
            logger.info "Showing collection %s." % @collection.tag_line
        else
            logger.info "No collection to show."
        end
        respond_to do |format|
            format.html
        end
    end

    protected

        def load_params
            @archive = Archive.find( params[:archive_id] )
            @collection = nil
            if params[:collection_id]
                @collection = Collection.find( params[:collection_id] )
            end
        end

end
