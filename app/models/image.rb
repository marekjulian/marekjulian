class Image < ActiveRecord::Base

    belongs_to :archive
    has_many   :image_variants, :dependent => :destroy
    has_many   :image_show_views
    has_and_belongs_to_many :collections

    accepts_nested_attributes_for :image_variants, :allow_destroy => true

    include Comparable

    def <=>(other)
        logger.debug "image - comparing #{self.id} with #{other.id}!"
        if self.master_variant_id and other.master_variant_id
            master = ImageVariant.find( self.master_variant_id )
            other_master = ImageVariant.find( other.master_variant_id )
            logger.debug "image - comparing masters: #{master.file_file_name} with #{other_master.file_file_name}!"
            master.file_file_name<=>other_master.file_file_name
        else
            self.image_variants.first<=>other.image_variants.first
        end

    end

end
