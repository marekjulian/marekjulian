class Cm::RootController < ApplicationController
  before_filter :login_required
  layout "cm"

  def index
    @archives = @current_user.archives
  end

end
