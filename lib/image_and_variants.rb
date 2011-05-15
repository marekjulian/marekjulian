module ImageAndVariants

    protected

        def resolve_image_variants( image )
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
            image.image_variants.each do |iv|
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
            image.image_variants.each do |iv|
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
            master_file_name = ""
            image.image_variants.each do |iv|
                if iv.is_master
                    image.master_variant_id = iv.id
                    master_file_name = iv.file_file_name
                end
                image.web_default_variant_id = iv.id if iv.is_web_default
                image.thumbnail_default_variant_id = iv.id if iv.is_thumbnail_default
            end
            if image.description == ""
                image.description = master_file_name
            end
            return true
        end

end
