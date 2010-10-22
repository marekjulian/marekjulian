class ImageVariant < ActiveRecord::Base

    belongs_to :image

    has_attached_file :file,
                      :storage => :s3,
                      :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                      :path => ':archive_id/images/:image_id/:basename.:extension',
                      :url => '/media_archives/:archive_id/images/:image_id/:basename.:extension'

    #
    # Can take take on one of 3 values:
    #   'saved', 'user', or 'auto'
    #
    attr_accessor :properties_mode

    before_save :set_dimensions

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
        if tmpFile.nil? then
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

    private

        def set_dimensions

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

end
