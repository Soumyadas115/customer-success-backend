class SprintsController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    def create
      begin
        body = JSON.parse(request.body.read)
  
        required_fields = %w[projectId userId startDate endDate status comments]
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
  
        sprint = Sprint.new(
            status: body['status'],
            startDate: body['startDate'],
            endDate: body['endDate'],
            comments: body['comments'],
            projectId: body['projectId']
        )
        sprint.save!
  
        render json: sprint, status: :created
      rescue => error
        render json: { error: error.message }, status: :internal_server_error
      end
    end
  
    def update
      begin
        body = JSON.parse(request.body.read)
        sprint = Sprint.find_by(id: params[:id])
        return render json: { error: "Sprint details not found" }, status: :not_found unless sprint
  
        user = User.find_by(id: body['userId'])
        return render json: { error: "User not found" }, status: :not_found unless user
  
        unless ["ADMIN", "MANAGER"].include?(user.role)
          return render json: { error: "You don't have the necessary permissions" }, status: :forbidden
        end
  
        sprint.update!(
            status: body['status'],
            startDate: body['startDate'],
            endDate: body['endDate'],
            comments: body['comments'],
        )
  
        render json: sprint, status: :ok
      rescue => error
        render json: { error: error.message }, status: :internal_server_error
      end
    end

    def destroy
        Sprint.transaction do
          body = JSON.parse(request.body.read)
          sprintId = params[:id]
    
          user = User.find_by(id: body['userId'])
          return render json: { error: "User not found" }, status: :not_found unless user
    
          unless user.role == "ADMIN" || user.role == "MANAGER"
            return render json: { error: "Insufficient permissions" }, status: :forbidden
          end
      
          sprint = Sprint.find_by(id: params[:id])
    
          unless sprint
            return render json: { error: "Sprint not found" }, status: :not_found
          end
      
          sprint.destroy
    
          render json: { message: "Sprint deleted successfully" }, status: :ok
        rescue => error
          render json: { error: error.message }, status: :internal_server_error
        end
      end
  end
  