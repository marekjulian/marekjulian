class ImageVariant < ActiveRecord::Base

    belongs_to :image

    has_attached_file :file,
                      :storage => :s3,
                      :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                      :path => ':archive_id/images/:image_id/:style/:basename.:extension',
                      :url => '/media_archives/:archive_id/images/:image_id/:style/:basename.:extension',
                      :styles => { :default_thumb => ["60x60#", :jpg],
                                   :web => ["600x600", :jpg] }



    #
    # Can take one of: 'none', 'add_image_variant', 'update_image_variant', or 'delete_image_variant'
    #
    attr_accessor :update_type
    #
    # Can take take on one of 3 values:
    #   'saved', 'user', or 'auto'
    #
    attr_accessor :attributes_mode
    #
    # Identifies an HTML id tag for an image_variant being added.
    #
    attr_accessor :list_elem_id

    # cancel post-processing now, and set flag...
    before_post_process :do_processing!

    before_save :set_dimensions

    # ...and perform post-processing after save in background
    after_save :schedule_processing

    def can_be_web_default
        height, width = self.dimensions
        if width == -1 and height == -1 then
            return true
        else
            if width >= 100 and height >= 100 and width <= 600 and height <= 600
                return true
            else
                return false
            end
        end
    end

    def can_be_thumbnail
        height, width = self.dimensions
        if width == -1 and height == -1 then
            return true
        else
            if width >= 20 and height >= 20 and width <= 100 and height <= 100
                return true
            else
                return false
            end
        end
    end

    def dimensions
        width = -1
        height = -1
        tmpFile = self.file.queued_for_write[ :original ]
        unless tmpFile.nil? then
            geom = Paperclip::Geometry.from_file( tmpFile )
            if geom then
                width = geom.width
                height = geom.height
            end
        else
            if self.file_width
                width = self.file_width
            end
            if self.file_height
                height = self.file_height
            end
        end
        return height, width
    end

    # generate styles (downloads original first)
    def regenerate_styles!
        logger.info "Regenerate styles for %d..." % self.id
        self.file.reprocess!
        self.processing = false
        self.save(false)
    end

    def file_changed?
        self.file_file_size_changed? ||
        self.file_file_name_changed? ||
        self.file_content_type_changed? ||
        self.updated_at_changed?
    end

    def url(style=:default_thumb)
        if self.processing
            # Show an image that reflects the style is in the processing of being created.
            self.file.url(style)
        else
            self.file.url(style)
        end
    end

    private

        # do_processing, set_dimensions and schedule_processing go in the order they are defined here.

        def do_processing!
            logger.info "ImageVariant.do_processing..."
            if self.file_changed? and self.is_master
                logger.info "ImageVariant.do_processing - setting processing = true."
                self.processing = true
                false # halts processing.
            end
        end

        def set_dimensions
            logger.info "ImageVariant.set_dimensions..."
            tmpFile = self.file.queued_for_write[ :original ]

            unless tmpFile.nil?
                begin
                    logger.info "Getting dimensions for image (%s), temp file is: %s." % [ self.file_file_name, tmpFile.path ]
                    gDimensions = Paperclip::Geometry.from_file( tmpFile )
                    self.file_width = gDimensions.width
                    self.file_height = gDimensions.height
                rescue Exception
                    logger.error "Cannot obtain dimensions for image (%s), temp file is: %s." % [ self.file_file_name, tmpFile.path ]
                end
            end
        end

        def schedule_processing
            logger.info "ImageVariant.schedule_processing..."
            if self.processing and self.file_changed?
                logger.info "ImageVariant.schedule_processing - Queuing image variant job for %d..." % self.id
                Delayed::Job.enqueue ImageVariantJob.new(self.id)
            end
        end

end
