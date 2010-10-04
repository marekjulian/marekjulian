class ImageVariant < ActiveRecord::Base

    belongs_to :image

    has_attached_file :file,
                      :storage => :s3,
                      :s3_credentials => "#{RAILS_ROOT}/config/s3.yml"
                      :path => '/:archive_id/images/:image_id/:basename.:extension',
                      :url => '/media_archives/:archive_id/images/:image_id/:basename.:extension'

    #
    # Can take take on one of 3 values:
    #   'saved', 'user', or 'auto'
    #
    attr_accessor :properties_mode

    def can_be_web_default
        geom = Paperclip::Geometry.from_file file.path
        if geom
            if geom.width >= 100 and geom.height >= 100 and geom.width <= 600 and geom.height <= 600
                return true
            else
                return false
            end
        end
        return true
    end

    def can_be_thumbnail
        geom = Paperclip::Geometry.from_file file.path
        if geom
            if geom.width >= 20 and geom.height >= 20 and geom.width <= 100 and geom.height <= 100
                return true
            else
                return false
            end
        end
        return true
    end

end
