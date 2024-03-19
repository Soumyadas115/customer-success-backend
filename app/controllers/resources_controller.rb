class ResourcesController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    def create
      begin
        body = JSON.parse(request.body.read)
  
        required_fields = %w[projectId userId name role comment startDate endDate]
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
  
        resource = Resource.new(
            projectId: body['projectId'],
            name: body['name'],
            startDate: body['startDate'],
            endDate: body['endDate'],
            role: body['role'],
            comment: body['comment'],
        )
        resource.save!
  
        render json: resource, status: :created
      rescue => error
        render json: { error: error.message }, status: :internal_server_error
      end
    end


  
    def update
      begin
        body = JSON.parse(request.body.read)
        resource = Resource.find_by(id: params[:id])
        return render json: { error: "Resource not found" }, status: :not_found unless resource
  
        user = User.find_by(id: body['userId'])
        return render json: { error: "User not found" }, status: :not_found unless user
  
        unless ["ADMIN", "MANAGER"].include?(user.role)
          return render json: { error: "You don't have the necessary permissions" }, status: :forbidden
        end
  
        resource.update!(
            name: body['name'],
            startDate: body['startDate'],
            endDate: body['endDate'],
            role: body['role'],
            comment: body['comment'],
        )
  
        render json: resource, status: :ok
      rescue => error
        render json: { error: error.message }, status: :internal_server_error
      end
    end


    def destroy
        begin
          body = JSON.parse(request.body.read)
          resource = Resource.find_by(id: params[:id])
          return render json: { error: "Resource not found" }, status: :not_found unless resource
    
          user = User.find_by(id: body['userId'])
          return render json: { error: "User not found" }, status: :not_found unless user
    
          unless ["ADMIN", "MANAGER"].include?(user.role)
            return render json: { error: "You don't have the necessary permissions" }, status: :forbidden
          end
    
          resource.destroy
    
          render json: { message: "Resource deleted successfully" }, status: :ok
        rescue => error
          render json: { error: error.message }, status: :internal_server_error
        end
      end
  end
  