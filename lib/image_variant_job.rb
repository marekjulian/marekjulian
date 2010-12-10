class ImageVariantJob < Struct.new(:image_variant_id)
    def perform
        Delayed::Worker.logger.debug("ImageVariantJob.perform - rails root = #{RAILS_ROOT}")
        ImageVariant.find(self.image_variant_id).regenerate_styles!
    end
end
