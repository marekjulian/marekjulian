# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

    def if_logged_in?
        yield if logged_in?
    end

    def if_recaptcha?
        yield if @bad_visitor
    end

end
