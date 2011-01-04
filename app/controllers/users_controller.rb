class UsersController < ApplicationController

    before_filter :store_location
    before_filter :login_from_session

    def show
        logger.info "Showing user:"
        logger.info params.inspect

        logger.info "Current user:"
        logger.info @current_user.inspect
        @user = User.find_by_login(params[:id])
        if not @current_user
            logger.info "No current user."
        end
        respond_to do |format|
            format.html
        end
    end

end
