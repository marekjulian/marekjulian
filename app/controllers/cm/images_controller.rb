class Cm::ImagesController < ApplicationController

    before_filter :login_required
    before_filter :load_params

    layout "cm"

    def show
        @image = Image.find(params[:id])

        respond_to do |format|
            format.html { render :action => "show" }
            format.xml  { render :xml => @image, :status => :showed, :location => @image }
        end
    end

    def new

        @image = Image.new

        1.upto(1) { @image.image_variants.build }

        @image.image_variants[0].is_master = true
        @image.image_variants[0].is_web_default = false
        @image.image_variants[0].is_thumbnail = false
        @image.image_variants[0].is_thumbnail_default = false
        @image.image_variants[0].properties_mode = 'auto'

        respond_to do |format|
            format.html # new.html.erb
            format.xml  { render :xml => @image }
        end
    end

    def create

        logger.info "Inspecting image."
        logger.info params[:image].inspect
        logger.info "About to create new image."

        @image = Image.new(params[:image])

        if @image
            ok = @archive.images << @image
            if ok && @collection
                ok = @collection.images << @image
            end
            ok = resolve_variants if ok
            @image.image_variants.each do | iv |
                ok = iv.save if ok
            end
            ok = @image.save if ok
        else
            ok = false
        end

        respond_to do |format|
            if @image and ok
                flash[:notice] = 'Image was successfully created.'
                format.html {
                    if @collection
                        redirect_to edit_cm_archive_collection_path( @archive, @collection )
                    else
                        redirect_to edit_cm_archive_path( @archive )
                    end
                }
                format.xml  { render :xml => @image, :status => :created, :location => @image }
            else
                format.html { render :action => "new" }
                format.xml  { render :xml => @album.errors, :status => :unprocessable_entity }
            end
        end
    end

    def edit
        @image = Image.find(params[:id])

        respond_to do |format|
            format.html { render :action => "edit" }
            format.xml  { render :xml => @image, :status => :edited, :location => @image }
        end
    end

    def update

        logger.info "Updating image, inspecting parameters:"
        logger.info params[:id].inspect
        logger.info "About to update image."

        @image = Image.find(params[:id])

        updated = false
        new_image_variant = nil
        if params[:delete_variant_id]
            ImageVariant.find( params[:delete_variant_id], :conditions => {:image_id => params[:id]}).destroy
            @image.save
            updated = true
        elsif params[:image]
            logger.info params[:image].inspect
            updated = @image.update_attributes( params[:image] )
            if params[:update_type] == 'add_image_variant'
                new_image_variant = @image.image_variants[ @image.image_variants.size - 1 ]
            end
        end
        if request.xhr?
            logger.info "Have an xhr request."
            if updated
                render :text => 'ok'
            else
                render :text => 'notOk'
            end
        else
            respond_to do |format|
                format.html { render :action => "edit" }
                format.xml  { render :xml => @image, :status => :edited, :location => @image }
                format.js   do
                    if params[:update_type] == 'add_image_variant' and updated
                        responds_to_parent do
                            render :update do |page|
                                if params[:list_elem_id]
                                    page[ params[:list_elem_id] ].remove
                                end
                                page.insert_html :before, :ImageVariantListElementAdd, :partial => "edit_image_variant",
                                :locals => { :image_variant => new_image_variant, :is_thumbnail => false }
                            end
                        end
                    end
                end
            end
        end
    end

    def destroy
        @image = Image.find(params[:id])
        @image.destroy

        respond_to do |format|
            format.html {
                if @collection
                    redirect_to edit_cm_archive_collection_path( @archive, @collection )
                else
                    redirect_to edit_cm_archive_path( @archive )
                end
            }
            format.xml  { head :ok }
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

    def resolve_variants
        #
        # Requirements:
        #   - is_master: only ONE
        #   - is_web_default: only ONE
        #   - is_thumbnail
        #   - is_thumbnail_default: only ONE and is_thumbnail must be true.
        #   - can have > 1 thumbnails
        # Do two scans of the image variants:
        #   scan 1: determine attributes:
        #     scan 1a:
        #       get (user.m, user.wd, user.td) and (saved.m, saved.wd, saved.td)
        #     ( m, wd, td ) = ( nil, nil, nil )
        #     update ( m, wd, td ) from values in user, if any
        #     update ( m, wd, td ) from values in saved, if not set.
        #     scan 1b:
        #       if iv.properties_mode == 'auto':
        #         m = iv if not m
        #         wd = iv if not wd
        #         td = iv if not td
        #         determine if it should be a thumbnail
        #       update iv based upon (m, wd, td), that is iv.is_master = true if iv == m, otherwise clear.
        #   scan 2: set the image level properties:
        #     - master_variant_id
        #     - web_default_variant_id
        #     - thumbnail_variant_id
        #
        user = {
            "master" => nil,
            "web_default" => nil,
            "thumbnail_default" => nil
        }
        saved = {
            "master" => nil,
            "web_default" => nil,
            "thumbnail_default" => nil
        }
        # scan 1a
        @image.image_variants.each do |iv|
            iv.is_thumbnail_default = false if not iv.is_thumbnail
            to_up = case iv.properties_mode
                   when 'user'
                       user
                   when 'saved'
                       saved
                   else
                       nil
                   end
            if to_up
                to_up['master'] = iv if not to_up['master'] and iv.is_master
                to_up['web_default'] = iv if not to_up['web_default'] and iv.is_web_default
                to_up['thumbnail_default'] = iv if not to_up['thumbnail_default'] and iv.is_thumbnail_default
            end
        end
        m = wd = td = nil
        m_fn = wd_fn = td_fn = ""
        m = user['master'] if user['master']
        m = saved['master'] if not m and saved['master']
        m_fn = m.file_file_name if m
        wd = user['web_default'] if user['web_default']
        wd = saved['web_default'] if not m and saved['web_default']
        wd_fn = wd.file_file_name if wd
        td = user['thumbnail_default'] if user['thumbnail_default']
        td = saved['thumbnail_default'] if not m and saved['thumbnail_default']
        td_fn = td.file_file_name if td
        logger.info "Initial default variants: %s, %s, %s" % [m_fn, wd_fn, td_fn]
        # scan 1b
        @image.image_variants.each do |iv|
            #
            # Compute ONLY for 'auto'. Means we might NOT have a 'web default' or 'thumbmail default'
            # if ONLY saved and/or user values exists without these values set.
            #
            if iv.properties_mode == 'auto'
                if not m
                    m = iv
                elsif m != iv and m.properties_mode == 'auto'
                    m_geom = Paperclip::Geometry.from_file m.file.path
                    iv_geom = Paperclip::Geometry.from_file iv.file.path
                    if iv_geom.height > m_geom.height and iv_geom.width >= m_geom.width or \
                        iv_geom.height >= m_geom.height and iv_geom.width > m_geom.width
                        m.is_master = false
                        m = iv
                    end
                end
                wd_ok = iv.can_be_web_default
                td_ok = iv.can_be_thumbnail
                logger.info "Updating auto properties: web default - " + wd_ok.to_s + ", can be thumbnail - " + td_ok.to_s
                wd = iv if not wd and iv.can_be_web_default
                iv.is_thumbnail = true if iv.can_be_thumbnail
                td = iv if not td and iv.is_thumbnail
                logger.info "Updated auto properties: %s, %s, %s, %s, %s (filename, is_master, is_web_default, is_thumbnail, is_thumbnail_default)." % \
                    [iv.file_file_name, iv.is_master, iv.is_web_default, iv.is_thumbnail, iv.is_thumbnail_default]
            end
            #
            # Must have a master regardless of what the user says.
            #
            m = iv if not m
            #
            # Set as appropriate
            #
            iv.is_master = iv == m
            iv.is_web_default = iv == wd
            iv.is_thumbnail_default = iv == td if iv.is_thumbnail
            m_fn = wd_fn = td_fn = ""
            m_fn = m.file_file_name if m
            wd_fn = wd.file_file_name if wd
            td_fn = td.file_file_name if td
            logger.info "Final selection: %s, %s, %s" % [m_fn, wd_fn, td_fn]
            logger.info "Final settings: %s, %s, %s, %s" % [iv.is_master, iv.is_web_default, iv.is_thumbnail, iv.is_thumbnail_default]
        end
        # scan 2
        @image.image_variants.each do |iv|
            @image.master_variant_id = iv.id if iv.is_master
            @image.web_default_variant_id = iv.id if iv.is_web_default
            @image.thumbnail_default_variant_id = iv.id if iv.is_thumbnail_default
        end
        return true
    end

end
