class Cm::ImagesController < ApplicationController

    before_filter :login_required
    before_filter :load_params

    layout "cm/cm"

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
        @image.image_variants[0].attributes_mode = 'auto'

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
            logger.info "Created new image, id = %d." % @image.id
            ok = @archive.images << @image
            if ok && @collection
                ok = @collection.images << @image
            end
            logger.info "Added image to archive and collection..."
            ok = resolve_variants if ok
            logger.info "Variants resolved, status = #{ok}."
            @image.image_variants.each do | iv |
                logger.info "Saving image variant, id = %d." % iv.id
                ok = iv.save if ok
                logger.info "Saved image variant, id = %d." % iv.id
            end
            logger.info "Saving image, id = %d." % @image.id
            ok = @image.save if ok
            logger.info "Saved image, id = #{@image.id}, status = #{ok}."
        else
            logger.info "Failed to create new image."
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
        logger.info params.inspect
        logger.info "About to update image."

        @image = Image.find(params[:id])
        logger.info("images_controller.update - image: id = #{@image.id}, master = #{@image.master_variant_id}, web_default = #{@image.web_default_variant_id}.")
        @image.image_variants.each do |iv|
            logger.info("images_controller.update - image: iv id = #{iv.id}, master = #{iv.is_master}, web_default = #{iv.is_web_default}, thumbnail = #{iv.is_thumbnail}, thumbnail default = #{iv.is_thumbnail_default}.")
        end
        @valid_image_variant_update_params = [ :update_type, :attributes_mode, :list_elem_id, :id, :file, :is_master, :is_web_default, :is_thumbnail, :is_thumbnail_default ]

        submitted_image_params = params[:image]
        submitted_image_params[:image_variants_attributes].each do | k,v |
            v.each do | kk, vv |
                if [ "is_master", "is_web_default", "is_thumbnail", "is_thumbnail_default" ].index(kk)
                    v[kk] = vv == "1"
                end
                if "id" == kk
                    v[kk] = vv.to_i
                end
            end
        end

        update_ok = true
        init_ok = true
        delete_ok = true
        update_ok = true
        post_update_ok = true

        init_ok, image_state = init_image_state
        delete_ok, had_deletions = process_deletions( image_state, submitted_image_params ) if init_ok
        update_ok, had_additions, had_updates, had_conflict_changes, had_auto_variants = process_additions_and_updates( image_state, submitted_image_params ) if init_ok and delete_ok
        if init_ok and delete_ok and update_ok and (had_additions or had_auto_variants)
            post_update_ok, had_post_add_changes, had_auto_updates = process_post_additions_and_updates image_state
        end
        if not init_ok or not delete_ok or not update_ok or not post_update_ok
            update_ok = false
        end

        logger.info("images_controller.update - after update, image: id = #{@image.id}, master = #{@image.master_variant_id}, web_default = #{@image.web_default_variant_id}.")
        @image.image_variants.each do |iv|
            logger.info("images_controller.update - after update, image: iv id = #{iv.id}, master = #{iv.is_master}, web_default = #{iv.is_web_default}, thumbnail = #{iv.is_thumbnail}, thumbnail default = #{iv.is_thumbnail_default}.")
        end

        if request.xhr?
            logger.info "Have an xhr request."
            respond_to do |format|
                format.json {
                    logger.info "Responding to json request..."
                    if update_ok
                        status = 0
                    else
                        status = 1
                    end
                    updated = []
                    @image.image_variants.each do |iv|
                        if iv.update_type == 'update_image_variant' and update_ok
                            new_html = render_to_string :partial => "edit_image_variant",
                                                        :locals => {  :image_variant => iv, :is_thumbnail => iv.is_thumbnail }
                            v = { :id => iv.list_elem_id,
                                  :html => new_html }
                            updated.push( v )
                        end
                    end
                    render :json => {  :status => status,
                                       :updated => updated },
                           :callback => "update_callback"
                }
                format.all {
                    logger.info "Responding with a default text response..."
                    if update_ok
                        render :text => 'ok'
                    else
                        render :text => 'notOk'
                    end
                }
            end
        else
            respond_to do |format|
                format.html { render :action => "edit" }
                format.xml  { render :xml => @image, :status => :edited, :location => @image }
                format.js do
                    @image.image_variants.each do |iv|
                        if iv.update_type == 'add_image_variant' and update_ok
                            responds_to_parent do
                                render :update do |page|
                                    if iv.list_elem_id
                                        page[ iv.list_elem_id ].remove
                                    end
                                    page.insert_html :before,
                                                     :ImageVariantListElementAdd,
                                                     :partial => "edit_image_variant",
                                                     :locals => { :image_variant => iv, :is_thumbnail => false }
                                end # render
                            end # responds_to_parent
                        elsif iv.update_type == 'update_image_variant' and update_ok
                            responds_to_parent do
                                render :update do |page|
                                    if iv.lilst_elem_id
                                        page[ iv.list_elem_id ].replace :partial => "edit_image_variant",
                                                                        :locals => {  :image_variant => iv, :is_thumbnail => iv.is_thumbnail }
                                    end
                                end
                            end
                        end # if
                    end # @image
                end # format.js
            end # respond_to
        end # request.xhr? else
    end # update

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
            #       if iv.attributes_mode == 'auto':
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
                logger.info "resolve_variants - scan 1a, iv #{iv.id}, attributes_mode #{iv.attributes_mode}, is_thumbnail #{iv.is_thumbnail}."
                iv.is_thumbnail_default = false if not iv.is_thumbnail
                to_up = case iv.attributes_mode
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
            logger.info "to_up (user) - (%s,%s,%s)." % [user["master"], user["web_default"], user["thumbnail_default"]]
            m = wd = td = nil
            m_fn = wd_fn = td_fn = ""
            m = user['master'] if user['master']
            m = saved['master'] if not m and saved['master']
            m_fn = m.file_file_name if m
            wd = user['web_default'] if user['web_default']
            wd = saved['web_default'] if not wd and saved['web_default']
            wd_fn = wd.file_file_name if wd
            td = user['thumbnail_default'] if user['thumbnail_default']
            td = saved['thumbnail_default'] if not td and saved['thumbnail_default']
            td_fn = td.file_file_name if td
            logger.info "Initial default variants: %s, %s, %s" % [m_fn, wd_fn, td_fn]
            # scan 1b
            @image.image_variants.each do |iv|
                #
                # Compute ONLY for 'auto'. Means we might NOT have a 'web default' or 'thumbmail default'
                # if ONLY saved and/or user values exists without these values set.
                #
                logger.info "resolve_variants - processing variant, id = %d, (%s,%s)." % [iv.id, iv.is_thumbnail, iv.is_thumbnail_default]
                if iv.attributes_mode == 'auto'
                    logger.info "resolve_variants - processing variant, auto properties, id = #{iv.id}, iv = #{iv}, m = #{m}."
                    if not m
                        logger.info "resolve_variants - assigning m."
                        m = iv
                        logger.info "resolve_variants - assigned m."
                    elsif m != iv and m.attributes_mode == 'auto'
                        logger.info "resolve_variants - Getting geometries."
                        m_geom = m.dimensions
                        m_geom_height = m_geom[0]
                        m_geom_width = m_geom[1]
                        iv_geom = iv.dimensions
                        iv_geom_height = iv_geom[0]
                        iv_geom_width = iv_geom[1]
                        logger.info "resolve_variants - Got geometries."
                        if iv_geom_height > m_geom_height and iv_geom_width >= m_geom_width or \
                            iv_geom_height >= m_geom_height and iv_geom_width > m_geom_width
                            m.is_master = false
                            m = iv
                        end
                    end
                    wd_ok = iv.can_be_web_default
                    td_ok = iv.can_be_thumbnail
                    logger.info "resolve_variants - Updating auto properties: web default - " + wd_ok.to_s + ", can be thumbnail - " + td_ok.to_s
                    wd = iv if not wd and iv.can_be_web_default
                    iv.is_thumbnail = true if iv.can_be_thumbnail
                    td = iv if not td and iv.is_thumbnail
                    logger.info "resolve_variants - Updated auto properties: %s, %s, %s, %s, %s (filename, is_master, is_web_default, is_thumbnail, is_thumbnail_default)." % \
                        [iv.file_file_name, iv.is_master, iv.is_web_default, iv.is_thumbnail, iv.is_thumbnail_default]
                end
                logger.info "resolve_variants - processing variant (after auto), id = %d, (%s,%s)." % [iv.id, iv.is_thumbnail, iv.is_thumbnail_default]
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

        def init_image_state
            image_state = {}
            image_state[:master_variant_id] = @image.master_variant_id
            image_state[:web_default_variant_id] = @image.web_default_variant_id
            image_state[:thumbnail_default_variant_id] = @image.thumbnail_default_variant_id
            had_invalid_initial_state = false
            iva = {}
            image_state[:image_variants_attributes] = iva
            @image.image_variants.each do |iv|
                iv_attr = {
                    :type => :existing,
                    :update_type => "none",
                    :attributes_mode => "none",
                    :id => iv.id,
                    :is_master => iv.is_master,
                    :is_web_default => iv.is_web_default,
                    :is_thumbnail => iv.is_thumbnail,
                    :is_thumbnail_default => iv.is_thumbnail_default,
                    :dirty => false
                }
                k = "e:#{iv.id}"
                iva[ k ] = iv_attr
                if iv.is_master and @image.master_variant_id != iv.id
                    image_state[:master_variant_id] = iv.id
                    had_invalid_initial_state = true
                end
                if iv.is_web_default and @image.web_default_variant_id != iv.id
                    image_state[:web_default_variant_id] = iv.id
                    had_invalid_initial_state = true
                end
                if iv.is_thumbnail_default and @image.thumbnail_default_variant_id != iv.id
                    image_state[:thumbnail_default_variant_id] = iv.id
                    had_invalid_initial_state = true
                end
            end
            ok = true
            if had_invalid_initial_state
                logger.info "images_controller.init_image_state - invalid initial state, saving, master = #{@image.master_variant_id}, web default = #{@image.web_default_variant_id}, thumbnail default = #{@image.thumbnail_default_variant_id}."
                @image.master_variant_id = image_state[:master_variant_id]
                @image.web_default_variant_id = image_state[:web_default_variant_id]
                @image.thumbnail_default_variant_id = image_state[:thumbnail_default_variant_id]
                ok = @image.save
                logger.info "images_controller.init_image_state - invalid initial state, after save, master = #{@image.master_variant_id}, web default = #{@image.web_default_variant_id}, thumbnail default = #{@image.thumbnail_default_variant_id}."
            end

            logger.info "images_controller.init_image_state, inspecting image_state:"
            logger.info image_state.inspect

            return ok, image_state
        end

        def process_deletions image_state, submitted_image_params
            ok = true
            had_deletions = false
            submitted_image_params[:image_variants_attributes].each do | submitted_key, submitted_iv |
                if submitted_iv[:update_type] == "delete_image_variant"
                    had_deletions = true
                    submitted_id = submitted_iv[:id]
                    k = "e:#{submitted_id}"
                    image_state[:image_variants_attributes][k][:type] = :deleted
                    if @image.master_variant_id == submitted_id
                        @image.master_variant_id = nil
                        image_state[:master_variant_id] = nil
                    end
                    if @image.web_default_variant_id == submitted_id
                        @image.web_default_variant_id = nil
                        image_state[:web_default_variant_id] = nil
                    end
                    if @image.thumbnail_default_variant_id == submitted_id
                        @image.thumbnail_default_variant_id = nil
                        image_state[:thumbnail_default_variant_id] = nil
                    end
                    iv = ImageVariant.find( submitted_id, :conditions => {:image_id => @image.id})
                    if iv
                        if iv.is_master
                            @image.master_variant_id = nil
                            image_state[:master_variant_id] = nil
                        end
                        if iv.is_web_default
                            @image.web_default_variant_id = nil
                            image_state[:web_default_variant_id] = nil
                        end
                        if iv.is_thumbnail_default
                            @image.thumbnail_default_variant_id = nil
                            image_state[:thumbnail_default_variant_id] = nil
                        end
                        logger.info "images_controller.process_deletions - destroying iv, id = #{submitted_id}"
                        destroy_ok = iv.destroy
                        logger.info "images_controller.process_deletions - destroying iv, id = #{submitted_id}, destroy_ok = #{destroy_ok}."
                        ok = false if not destroy_ok
                    end
                end
            end
            if had_deletions
                save_ok = @image.save
                ok = false if not save_ok
                logger.info "images_controller.process_deletions - image saved, id = #{@image.id}, ok = #{ok}, master_variant_id = #{@image.master_variant_id}, web_default_variant_id = #{@image.web_default_variant_id}."
            end
            return ok, had_deletions
        end

        def process_additions_and_updates image_state, submitted_image_params
            #
            # Processes any image_variants in submitted_image_params which are being 'added' or 'updated'.
            # Adjusts image_state accordingly.
            #
            # Types of image variants are identified by this tuple:
            #   ( :type, :attributes_mode ), where:
            #     :type -> :existing | :new
            #     :attributes_mode -> "none"| "user" | "auto"
            # Possible types of iv's:
            #   ( :existing, :none ) - No update values provided. Although other ( :existing, :user ) or ( :new, :user ) value can
            #     cause a change in this iv.
            #   ( :existing, :user ) - User supplied values. Can be overridden if other ( *, :user ) iv was found earlier which
            #     would take precedence.
            #   ( :new, :user ) - User supplied values. Can be overriden as in ( :existing, :user ).
            #   ( :new, :auto ) - Values will computed latter, after upload via resolve_attributes_after_update.
            #
            # How attributes are set and affect other variants:
            #   - (:existing, :none) - can't affect anyone else. Values can be overridden by other (:existing, :user), or (:new, :user)
            #     iv's which take precedence.
            #   - (:existing, :user) - Change can override ANY other iv ( (:existing, :none), (:existing, :user) or
            #       (:existing, :auto), or (:new, *)). Can also be overriden by other (:existing, :user) which was encountered
            #       earlier.
            #   - (:new, :user) - See (:existing, :user).
            #   - (:new, :auto) - At this stage, all attributes take default values. The iv attributes are computed by
            #       resolve_attributes_after_update.
            #
            # There are 3 attributes, which can be set on ONE and ONLY one iv:
            #   - is_master, is_web_default and is_thumbnail_default
            #
            # Returns:
            #   ( ok, had_additions, had_updates, had_conflict_updates, had_auto_variants )
            #
            #
            #
            ok = true
            had_additions = false
            had_updates = false
            had_conflict_updates = false
            had_auto_variants = false

            user_attributes = {
                :master => nil,
                :web_default => nil,
                :thumbnail_default => nil
            }

            image_state_iva = image_state[:image_variants_attributes]
            #
            # pass 1:
            #   - Update image_state's 'image_variant attributes' and user_attributes based upon submitted_image_params:
            #
            submitted_image_params[:image_variants_attributes].each do |id, attr|
                if attr.key?(:id)
                    k = "e:#{attr["id"]}"
                    if image_state_iva.key?(k)
                        iv_attr = image_state_iva[k]
                    else
                        iv_attr = { }
                    end
                    iv_attr[:type] = :existing
                    iv_attr[:update_type] = attr[:update_type]
                    iv_attr[:attributes_mode] = "none"
                else
                    changes = true
                    k = "n:#{id}"
                    iv_attr = { }
                    iv_attr[:type] = :new
                    iv_attr[:update_type] = attr[:update_type]
                    iv_attr[:attributes_mode] = "none"
                    iv_attr[:file] = attr[:file] if attr[:file]
                end
                iv_attr[:list_elem_id] = attr[:list_elem_id] if attr[:list_elem_id]
                if attr.key?(:attributes_mode)
                    mode = attr[:attributes_mode]
                    mode = "auto" if not [ "none", "user", "auto" ].index( mode )
                    iv_attr[:attributes_mode] = mode
                elsif not iv_attr.key?(:attributes_mode)
                    iv_attr[:attributes_mode] = "auto"

                end
                iv_attr[:submitted_image_params_key] = id
                tmp_iv_attr = { }
                iv_attr.each do |iv_attr_k, iv_attr_v|
                    tmp_iv_attr[iv_attr_k] = iv_attr_v
                end
                if tmp_iv_attr[:attributes_mode] == "auto"
                    had_auto_variants = true
                    tmp_iv_attr[:is_master] = false
                    tmp_iv_attr[:is_web_default] = false
                    tmp_iv_attr[:is_thumbnail] = false
                    tmp_iv_attr[:is_thumbnail_default] = false
                elsif tmp_iv_attr[:attributes_mode] == "user"
                    tmp_iv_attr[:is_master] = false
                    tmp_iv_attr[:is_web_default] = false
                    tmp_iv_attr[:is_thumbnail] = false
                    tmp_iv_attr[:is_thumbnail] = true if tmp_iv_attr[:is_thumbnail] != attr[:is_thumbnail]
                    tmp_iv_attr[:is_thumbnail_default] = false
                    if not user_attributes[:master] and attr[:is_master]
                        tmp_iv_attr[:is_master] = attr[:is_master]
                        user_attributes[:master] = k
                    end
                    if not user_attributes[:web_default] and attr[:is_web_default]
                        tmp_iv_attr[:is_web_default] = attr[:is_web_default]
                        user_attributes[:web_default] = k
                    end
                    if not user_attributes[:thumbnail_default] and attr[:is_thumbnail_default]
                        tmp_iv_attr[:is_thumbnail_default] = attr[:is_thumbnail_default]
                        user_attributes[:thumbnail_default] = k
                    end
                elsif tmp_iv_attr[:type] == :new
                    tmp_iv_attr[:is_master] = false
                    tmp_iv_attr[:is_web_default] = false
                    tmp_iv_attr[:is_thumbnail] = false
                    tmp_iv_attr[:is_thumbnail_default] = false
                end
                [ :is_master, :is_web_default, :is_thumbnail, :is_thumbnail_default ].each do | attr_k |
                    if iv_attr[ attr_k ] != tmp_iv_attr[ attr_k ]
                        iv_attr[ attr_k ] = tmp_iv_attr[ attr_k ]
                        iv_attr[:dirty] = true
                        had_additions = true if iv_attr[:update_type] == "add_image_variant"
                        had_updates = true if iv_attr[:update_type] == "update_image_variant"
                    end
                end

                image_state_iva[ k ] = iv_attr
            end

            #
            # - Update image_state's 'image_variant attributes' from user_attributes
            # - Update image_state's 'image attributes' to reflect any changes
            # - Add any changed attributes to update_params
            #
            update_params = { }
            image_state_iva.each do |k, attr|
                tmp_attr = { }
                attr.each do |iv_attr_k, iv_attr_v|
                    tmp_attr[iv_attr_k] = iv_attr_v
                end
                if attr[:properties_mode] != "auto"
                    tmp_attr[:is_master] = false if user_attributes[:master] and user_attributes[:master] != k
                    tmp_attr[:is_web_default] = false if user_attributes[:web_default] and user_attributes[:web_default] != k
                    tmp_attr[:is_thumbnail_default] = false if user_attributes[:thumbnail_default] and user_attributes[:thumbnail_default] != k
                end
                [ :is_master, :is_web_default, :is_thumbnail, :is_thumbnail_default ].each do | attr_k |
                    if attr[ attr_k ] != tmp_attr[ attr_k ]
                        attr[ attr_k ] = tmp_attr[ attr_k ]
                        attr[:dirty] = true
                        if attr[:update_type] == "add_image_variant"
                            had_additions = true
                        elsif attr[:update_type] == "update_image_variant"
                            had_updates = true
                        else
                            had_conflict_updates = true
                        end
                    end
                end
                if attr[:dirty] or (attr[:type] == :new and attr[:file])
                    update_params[:image_variants_attributes] = { } if not update_params.key? :image_variants_attributes
                    update_params_attr = { } if not update_params[:image_variants_attributes].key? k
                    update_params[:image_variants_attributes][k] = update_params_attr
                    @valid_image_variant_update_params.each do | update_params_key |
                        update_params_attr[ update_params_key ] = attr[ update_params_key ] if attr.key? update_params_key
                    end
                end
                if attr.key?(:id)
                    image_state[:master_variant_id] = attr[:id] if attr[:is_master]
                    image_state[:web_default_variant_id] = attr[:id] if attr[:is_web_default]
                    image_state[:thumbnail_default_variant_id] = attr[:id] if attr[:is_thumbnail_default]
                    if @image.master_variant_id != image_state[:master_variant_id]
                        update_params[:master_variant_id] = image_state[:master_variant_id]
                        had_updates = true
                    end
                    if @image.web_default_variant_id != image_state[:web_default_variant_id]
                        update_params[:web_default_variant_id] = image_state[:web_default_variant_id]
                        had_updates = true
                    end
                    if @image.thumbnail_default_variant_id != image_state[:thumbnail_default_variant_id]
                        update_params[:thumbnail_default_variant_id] = image_state[:thumbnail_default_variant_id]
                        had_updates = true
                    end
                end
            end

            logger.info "images_controller.process_additions_and_updates - image_state:"
            logger.info image_state.inspect
            logger.info "images_controller.process_additions_and_updates - update_params:"
            logger.info update_params.inspect

            if update_params.length() > 0
                ok = @image.update_attributes update_params
            end

            return ok, had_additions, had_updates, had_conflict_updates, had_auto_variants
        end

    def process_post_additions_and_updates image_state
        #
        # Go through the image_variants in image_state, and:
        #   1. update image_variant attributes due to 'auto' update changes.
        #   2. deal with updating @image level attributes due to 'additions' or 'auto' update changes.
        #
        ok = true
        had_post_add_changes = false
        had_auto_updates = false

        #
        # 1. process ALL the 'auto' updates.
        #
        begin
            master_iv = ImageVariant.find( @image.master_variant_id ) if @image.master_variant_id
            master_iv_id = master_iv.id
        rescue
            master_iv = nil
            master_iv_id = nil
        end
        begin
            web_default_iv = ImageVariant.find( @image.web_default_variant_id ) if @image.web_default_variant_id
            web_default_iv_id = web_default_iv.id
            logger.info "process_post_additions_and_updates - web default iv = %s" % [web_default_iv.id]
        rescue
            web_default_iv = nil
            web_default_iv_id = nil
        end
        begin
            thumbnail_default_iv = ImageVariant.find( @image.thumbnail_default_variant_id ) if @image.thumbnail_default_variant_id
            thumbnail_default_iv_id = thumbnail_default_iv.id
        rescue
            thumbnail_default_iv = nil
            thumbnail_default_iv_id = nil
        end
        logger.info "process_post_additions_and_updates - defaults = (%s, %s, %s)." % [master_iv_id, web_default_iv_id, thumbnail_default_iv_id]
        @image.image_variants.each do |iv|
            if iv.attributes_mode == "auto"
                if not master_iv
                    master_iv = iv
                elsif master_iv != iv
                    master_iv_geom = master_iv.dimensions
                    master_iv_height = master_iv_geom[0]
                    master_iv_width = master_iv_geom[1]
                    logger.info "process_post_additions_and_updates - master image variant dimentions (%d, %d)." % [master_iv_width, master_iv_height]
                    iv_geom = iv.dimensions
                    iv_height = iv_geom[0]
                    iv_width = iv_geom[1]
                    logger.info "process_post_additions_and_updates - image variant dimentions (%d, %d)." % [iv_width, iv_height]
                    if iv_height > master_iv_height and iv_width >= master_iv_width or \
                        iv_height >= master_iv_height and iv_width > master_iv_width
                        master_iv.is_master = false
                        master_iv = iv
                    end
                end
                wd_ok = iv.can_be_web_default
                td_ok = iv.can_be_thumbnail
                logger.info "process_post_additions_and_updates - Updating auto properties: web default - " + wd_ok.to_s + ", can be thumbnail - " + td_ok.to_s
                web_default_iv = iv if not web_default_iv and iv.can_be_web_default
                iv.is_thumbnail = true if iv.can_be_thumbnail
                thumbnail_default_iv = iv if not thumbnail_default_iv and iv.is_thumbnail
                logger.info "process_post_additions_and_updates - Updated auto properties: %s, %s, %s, %s, %s (filename, is_master, is_web_default, is_thumbnail, is_thumbnail_default)." % \
                    [iv.file_file_name, iv.is_master, iv.is_web_default, iv.is_thumbnail, iv.is_thumbnail_default]
            end
            logger.info "process_post_additions_and_updates - processing variant (after auto), id = %d, (%s, %s, %s, %s)." % [iv.id, iv.is_master, iv.is_web_default, iv.is_thumbnail, iv.is_thumbnail_default]
            #
            # Must have a master regardless of what the user says.
            #
            master_iv = iv if not master_iv
            #
            # Set as appropriate
            #
            if master_iv != nil and iv.is_master != (iv == master_iv)
                iv.is_master = iv == master_iv
                had_post_add_changes = true if iv.update_type == "add_image_variant"
                had_auto_updates = true if iv.attributes_mode == "auto"
            end
            logger.info "process_post_additions_and_updates - id = %s, is_web_default = %s, iv == web_default_iv = %s." % [iv.id, iv.is_web_default, iv == web_default_iv]
            if web_default_iv != nil and iv.is_web_default != (iv == web_default_iv)
                iv.is_web_default = iv == web_default_iv
                had_post_add_changes = true if iv.update_type == "add_image_variant"
                had_auto_updates = true if iv.attributes_mode == "auto"
            end
            if thumbnail_default_iv != nil and iv.is_thumbnail_default != (iv == thumbnail_default_iv)
                iv.is_thumbnail_default = iv == thumbnail_default_iv
                had_post_add_changes = true if iv.update_type == "add_image_variant"
                had_auto_updates = true if iv.attributes_mode == "auto"
            end
            master_fn = web_default_fn = thumbnail_default_fn = ""
            master_fn = master_iv.file_file_name if master_iv
            web_default_fn = web_default_iv.file_file_name if web_default_iv
            thumbnail_default_fn = thumbnail_default_iv.file_file_name if thumbnail_default_iv
            logger.info "Final settings: %s, %s, %s, %s" % [iv.is_master, iv.is_web_default, iv.is_thumbnail, iv.is_thumbnail_default]
        end

        @image.image_variants.each do |iv|
            @image.master_variant_id = iv.id if iv.is_master
            @image.web_default_variant_id = iv.id if iv.is_web_default
            @image.thumbnail_default_variant_id = iv.id if iv.is_thumbnail_default
        end

        if had_post_add_changes or had_auto_updates
            ok = @image.save
        end

        return ok, had_post_add_changes, had_auto_updates

    end

end
