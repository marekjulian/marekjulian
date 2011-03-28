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
        elsif imageVariant.is_master
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
            if showView.thumbnail_variant_id
                showVariant = ImageVariant.find( showView.thumbnail_variant_id )
                if showVariant
                    thumbnailElem = image_tag showVariant.file.url, :id => imageTagId, :class => imageClass, :alt => "", :border => 0
                end
            else
                image = Image.find( showView.image_id )
                if image
                    image.image_variants.each do | imageVariant |
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

    def organizer_portfolio_collection_thumbnail_tag( portfolioCollection, imageTagId, imageClass )
        thumbnailElem = ""
        if portfolioCollection.default_show_view_id
            showView = ImageShowView.find( portfolioCollection.default_show_view_id )
        else
            showView = nil
        end
        if showView
            if showView.thumbnail_variant_id
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

    def organizer_missing_image_thumbnail_tag( imageTagId, imageClass )
        image_tag 'camera_60x60px.gif', :id => imageTagId, :class => imageClass, :alt => "", :border => 0
    end

end
