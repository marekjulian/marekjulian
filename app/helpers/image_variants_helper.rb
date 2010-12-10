module ImageVariantsHelper

  def image_variant_tag( image_variant )
    logger.info "Generating image variant tag for url - #{image_variant.file.url}."
    image_tag image_variant.file.url, :alt => "", :border => 0
  end

  def default_thumb_tag( image_variant )
    if image_variant.is_master
      image_tag image_variant.file.url(:default_thumb), :alt => "", :border => 0
    else
      ""
    end
  end

  def web_tag( image_variant )
    if image_variant.is_master
      image_tag image_variant.file.url(:web), :alt => "", :border => 0
    else
      ""
    end
  end

  def image_variant_type_string( image_variant, prefix, postfix )
    t_str = ""
    if image_variant.is_master
      t_str = prefix + "Master" + postfix
    elsif image_variant.is_thumbnail
      t_str = prefix + "Thumbnail" + postfix
    elsif image_variant.is_web_default
      t_str = prefix + "Web Default" + postfix
    end
  end

  def image_variant_file_size_str( image_variant )
    size = image_variant.file_file_size.to_f
    units = ""

    if size > 1024.00
        size = size / 1024.00
        units = "K"
    end

    if size > 1024.00
        size = size / 1024.00
        units = "M"
    end

    if size > 1024.00
        size = size / 1024.00
        units = "G"
    end

    if units != ""
        "%.2f %s" % [ size, units ]
    else
        "%.2f" % size
    end
  end

    def dimensions_str( image_variant )
        width = '?'
        height = '?'
        if image_variant.file_width != nil
            width = image_variant.file_width.to_s
        end
        if image_variant.file_height != nil
            height = image_variant.file_height.to_s
        end
        width + " x " + height
    end

end
