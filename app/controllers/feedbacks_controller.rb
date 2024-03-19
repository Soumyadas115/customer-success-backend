class FeedbacksController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    def create
      begin
        body = JSON.parse(request.body.read)
  
        required_fields = %w[projectId userId date body type action closureDate]
        if required_fields.any? { |field| body[field].blank? }
            return render json: { error: 'Missing required fields' }, status: :bad_request
        end
  
        user = User.find_by(id: body['userId'])
        return render json: { error: "User not found" }, status: :not_found unless user
  
        unless ["ADMIN", "MANAGER"].include?(user.role)
          return render json: { error: "You don't have the necessary permissions" }, status: :forbidden
        end
  
        project = Project.find_by(id: body['projectId'])
        return render json: { error: "Project not found" }, status: :not_found unless project
  
        feedback = Feedback.new(
            projectId: body['projectId'],
            body: body['body'],
            date: body['date'],
            type: body['type'],
            action: body['action'],
            closureDate: body['closureDate']
        )
        feedback.save!
  
        render json: feedback, status: :created
      rescue => error
        render json: { error: error.message }, status: :internal_server_error
      end
    end


  
    def update
      begin
        body = JSON.parse(request.body.read)
        feedback = Feedback.find_by(id: params[:id])
        return render json: { error: "Feedback not found" }, status: :not_found unless feedback
  
        user = User.find_by(id: body['userId'])
        return render json: { error: "User not found" }, status: :not_found unless user
  
        unless ["ADMIN", "MANAGER"].include?(user.role)
          return render json: { error: "You don't have the necessary permissions" }, status: :forbidden
        end
  
        feedback.update!(
            body: body['body'],
            date: body['date'],
            type: body['type'],
            action: body['action'],
            closureDate: body['closureDate']
        )
  
        render json: feedback, status: :ok
      rescue => error
        render json: { error: error.message }, status: :internal_server_error
      end
    end


    def destroy
        begin
          body = JSON.parse(request.body.read)
          feedback = Feedback.find_by(id: params[:id])
          return render json: { error: "Feedback not found" }, status: :not_found unless feedback
    
          user = User.find_by(id: body['userId'])
          return render json: { error: "User not found" }, status: :not_found unless user
    
          unless ["ADMIN", "MANAGER"].include?(user.role)
            return render json: { error: "You don't have the necessary permissions" }, status: :forbidden
          end
    
          feedback.destroy
    
          render json: { message: "Feedback deleted successfully" }, status: :ok
        rescue => error
          render json: { error: error.message }, status: :internal_server_error
        end
      end
  end
  