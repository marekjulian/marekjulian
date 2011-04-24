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
        if thumbnailVariant
            thumbnailElem = image_tag thumbnailVariant.file.url, :id => imageTagId, :class => imageClass, :alt => "", :border => 0
        elsif masterVariant
            thumbnailElem = image_tag masterVariant.file.url(:default_thumb), :id => imageTagId, :class => imageClass, :alt => "", :border => 0
        end
        if thumbnailElem == ""
            thumbnailElem = image_tag 'camera_60x60px.gif', :id => imageTagId, :class => imageClass, :alt => "", :border => 0
        end
        thumbnailElem
    end

    def organizer_image_variant_tag( imageVariant, tagId, tagClass )
        thumbnailElem = ""
        if imageVariant.is_thumbnail
            thumbnailElem = image_tag imageVariant.file.url, :id => tagId, :class => tagClass, :alt => "", :border => 0
        elsif imageVariant.file.exists? :default_thumb
            thumbnailElem = image_tag imageVariant.file.url(:default_thumb), :id => tagId, :class => tagClass, :alt => "", :border => 0
        end
        if thumbnailElem == ""
            thumbnailElem = image_tag 'camera_60x60px.gif', :id => tagId, :class => tagClass, :alt => "", :border => 0
        end
        thumbnailElem
    end

    def organizer_portfolio_thumbnail_tag( portfolio, imageTagId, imageClass )
        thumbnailElem = ""
        if portfolio.default_show_view_id
            showView = ImageShowView.find( portfolio.default_show_view_id )
        else
            showView = nil
        end
        if showView
            if showView.thumbnail_variant_id and ImageVariant.exists?( showView.thumbnail_variant_id )
                showVariant = ImageVariant.find( showView.thumbnail_variant_id )
                thumbnailElem = image_tag showVariant.file.url, :id => imageTagId, :class => imageClass, :alt => "", :border => 0
            else
                image = Image.find( showView.image_id )
                if image
                    image.image_variants.each do | imageVariant |
                        if imageVariant.is_master and imageVariant.file.exists? :default_thumb
                            thumbnailElem = image_tag imageVariant.file.url(:default_thumb), :id => imageTagId, :class => imageClass, :alt => "", :border => 0
                        end
                    end
                end
            end
        end
        if thumbnailElem == ""
            thumbnailElem = image_tag 'camera_60x60px.gif', :id => imageTagId, :class => imageClass, :alt => "", :border => 0
        end
        thumbnailElem
    end

    def organizer_portfolio_collection_thumbnail_tag( portfolioCollection, imageTagId, imageClass )
        thumbnailElem = ""
        if portfolioCollection.default_show_view_id and ImageShowView.exists?( portfolioCollection.default_show_view_id )
            showView = ImageShowView.find( portfolioCollection.default_show_view_id )
        else
            showView = nil
        end
        if showView
            if showView.thumbnail_variant_id and ImageVariant.exists?( showView.thumbnail_variant_id )
                showVariant = ImageVariant.find( showView.thumbnail_variant_id )
                if showVariant
                    thumbnailElem = image_tag showVariant.file.url, :id => imageTagId, :class => imageClass, :alt => "", :border => 0
                end
            else
                image = Image.find( showView.image_id )
                if image
                    image.image_variants.each do |imageVariant|
                        if imageVariant.is_master
                            thumbnailElem = image_tag imageVariant.file.url(:default_thumb), :id => imageTagId, :class => imageClass, :alt => "", :border => 0
                        end
                    end
                end
            end
        end
        if thumbnailElem == ""
            thumbnailElem = image_tag 'camera_60x60px.gif', :id => imageTagId, :class => imageClass, :alt => "", :border => 0
        end
        thumbnailElem
    end

    def organizer_image_show_view_thumbnail_tag( show_view, image_tag_id, image_tag_class )
        thumbnail_elem = ""
        if show_view
            if show_view.thumbnail_variant_id and ImageVariant.exists?( show_view.thumbnail_variant_id )
                show_variant = ImageVariant.find( show_view.thumbnail_variant_id )
                if show_variant
                    thumbnail_elem = image_tag show_variant.file.url, :id => image_tag_id, :class => image_tag_class, :alt => "", :border => 0
                end
            else
                image = Image.find( show_view.image_id )
                if image
                    image.image_variants.each do |imageVariant|
                        if imageVariant.is_master
                            thumbnail_elem = image_tag imageVariant.file.url(:default_thumb), :id => image_tag_id, :class => image_tag_class, :alt => "", :border => 0
                        end
                    end
                end
            end
        end
        if thumbnail_elem == ""
            thumbnail_elem = image_tag 'camera_60x60px.gif', :id => image_tag_id, :class => image_tag_class, :alt => "", :border => 0
        end
        thumbnail_elem
    end

    def organizer_missing_image_thumbnail_tag( imageTagId, imageClass )
        image_tag 'camera_60x60px.gif', :id => imageTagId, :class => imageClass, :alt => "", :border => 0
    end

end
