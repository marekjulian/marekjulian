module Port::PortfolioCollectionsHelper
    def show_view_thumbnail_tag( show_view )
        thumbnail_elem = ""
        if show_view
            if show_view.thumbnail_variant_id and ImageVariant.exists?( show_view.thumbnail_variant_id )
                show_variant = ImageVariant.find( show_view.thumbnail_variant_id )
                if show_variant and show_variant.is_thumbnail
                    thumbnail_elem = image_tag show_variant.file.url, :alt => "", :border => 0
                end
            end
            if thumbnail_elem == ""
                image = Image.find( show_view.image_id )
                if image
                    image.image_variants.each do |imageVariant|
                        if imageVariant.is_master
                            thumbnail_elem = image_tag imageVariant.file.url(:default_thumb), :alt => "", :border => 0
                        end
                    end
                end
            end
        end
        if thumbnail_elem == ""
            thumbnail_elem = image_tag 'camera_60x60px.gif', :alt => "", :border => 0
        end
        thumbnail_elem
    end

    def show_view_show_tag( show_view )
        show_elem = ""
        if show_view
            if show_view.show_variant_id and ImageVariant.exists?( show_view.show_variant_id )
                show_variant = ImageVariant.find( show_view.show_variant_id )
                if show_variant
                    show_elem = image_tag show_variant.file.url, :alt => "", :border => 0
                end
            else
                image = Image.find( show_view.image_id )
                if image
                    image.image_variants.each do |imageVariant|
                        if imageVariant.is_master
                            show_elem = image_tag imageVariant.file.url(:web), :alt => "", :border => 0
                        end
                    end
                end
            end
        end
        if show_elem == ""
            show_elem = image_tag 'camera_60x60px.gif', :alt => "", :border => 0
        end
        show_elem
    end

end
