Paperclip::Attachment.interpolations[:username] = proc do |attachment, style|
  "marekjulian"
end

Paperclip::Attachment.interpolations[:archive_id] = proc do |attachment, style|
    @image = Image.find( attachment.instance.image_id)
    @image.archive_id
end

Paperclip::Attachment.interpolations[:image_id] = proc do |attachment, style|
  attachment.instance.image_id
end

