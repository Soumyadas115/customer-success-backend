class UpdatesController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    def create
      begin
        body = JSON.parse(request.body.read)
  
        required_fields = %w[projectId userId date body]
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
  
        update = Update.new(
            projectId: body['projectId'],
            body: body['body'],
            date: body['date'],
        )
        update.save!
  
        render json: update, status: :created
      rescue => error
        render json: { error: error.message }, status: :internal_server_error
      end
    end


  
    def update
      begin
        body = JSON.parse(request.body.read)
        update = Update.find_by(id: params[:id])
        return render json: { error: "Update not found" }, status: :not_found unless update
  
        user = User.find_by(id: body['userId'])
        return render json: { error: "User not found" }, status: :not_found unless user
  
        unless ["ADMIN", "MANAGER"].include?(user.role)
          return render json: { error: "You don't have the necessary permissions" }, status: :forbidden
        end
  
        update.update!(
            body: body['body'],
            date: body['date'],
            isEdited: true,
        )
  
        render json: update, status: :ok
      rescue => error
        render json: { error: error.message }, status: :internal_server_error
      end
    end


    def destroy
        begin
          body = JSON.parse(request.body.read)
          update = Update.find_by(id: params[:id])
          return render json: { error: "Update not found" }, status: :not_found unless update
    
          user = User.find_by(id: body['userId'])
          return render json: { error: "User not found" }, status: :not_found unless user
    
          unless ["ADMIN", "MANAGER"].include?(user.role)
            return render json: { error: "You don't have the necessary permissions" }, status: :forbidden
          end
    
          update.destroy
    
          render json: { message: "Update deleted successfully" }, status: :ok
        rescue => error
          render json: { error: error.message }, status: :internal_server_error
        end
      end
  end
  