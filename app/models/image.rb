class Image < ActiveRecord::Base

    belongs_to :archive
    has_many   :image_variants, :dependent => :destroy
    has_many   :image_show_views
    has_and_belongs_to_many :collections

    accepts_nested_attributes_for :image_variants, :allow_destroy => true

    def image_variants_attributes=(attributes)
        attributes.keys.each do |attribute|
            logger.info "image_variants_attributes: inspecting attribute - "
            logger.info attributes[attribute].inspect
            if attributes[attribute].is_a? Hash
                added_attr = attributes[attribute]
                image_variants.build( added_attr )
            elsif attributes[attribute].is_a? Array
                logger.info "image_variants_attributes: inspecting attribute (array):"
                attributes[attribute].each do | added_attr |
                    logger.info added_attr.inspect
                    image_variants.build( added_attr )
                end
            end
        end
    end

end
