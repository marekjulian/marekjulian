module GalleryHelper
    def lightbox2_image_tag( collection, image )
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
                thumbnailElem = image_variant_tag thumbnailVariant
            else
                thumbnailElem = default_thumb_tag masterVariant
            end
        end
        if webDefaultVariant
            webDefaultUrl = webDefaultVariant.file.url
        elsif masterVariant
            webDefaultUrl = masterVariant.file.url(:web)
        else
            webDefaultUrl = nil
        end
        if webDefaultUrl and thumbnailElem
            link_to thumbnailElem, webDefaultUrl, :rel => "lightbox[%s]" % collection.tag_line
        end
    end
end
