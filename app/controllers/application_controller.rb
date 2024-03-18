class ApplicationController < ActionController::Base

    private

    def getUserById(userId)
        User.find_by(id: userId)
    end

    def getUserByEmail(userEmail)
        User.find_by(email: userEmail)
    end
    
    helper_method :getUserById, :getUserByEmail
end
