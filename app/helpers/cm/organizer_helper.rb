module Cm::OrganizerHelper

    def organizer_image_tag( image, imageTagId, imageClass )
        masterVariant = nil
        webDefaultVariant = nil
        thumbnailVariant = nil
        image.image_variants.each do | imageVariant |
            if imageVariant.is_master
                masterVariant = imageVariant
            end
            if imageVariant.is_web_default
                webDefaultVariant = imageVariant
            end
            if imageVariant.is_thumbnail
                thumbnailVariant = imageVariant
            end
        end
        thumbnailElem = ""
        if masterVariant or thumbnailVariant
            if thumbnailVariant
                thumbnailElem = image_tag thumbnailVariant.file.url, :id => imageTagId, :class => imageClass, :alt => "", :border => 0
            else
                thumbnailElem = image_tag masterVariant.file.url(:default_thumb), :id => imageTagId, :class => imageClass, :alt => "", :border => 0
            end
        end
        thumbnailElem
    end

end
