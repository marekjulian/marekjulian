class Role < ActiveRecord::Base

  attr_accessible nil  

  def to_xml(options = {})
    #Add attributes accessible by xml
    #Ex. default_only = [:id, :name]
    default_only = []
    options[:only] = (options[:only] || []) + default_only
    super(options)
  end
  
end
