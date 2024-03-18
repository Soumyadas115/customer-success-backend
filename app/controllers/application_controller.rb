class ApplicationController < ActionController::Base

    private

    def getUserById(user_id)
        User.find_by(id: user_id)
    end

    def getUserByEmail(user_email)
        User.find_by(email: user_email)
    end
    
    helper_method :getUserById, :getUserByEmail
end
