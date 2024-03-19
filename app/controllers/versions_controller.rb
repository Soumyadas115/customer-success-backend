class VersionsController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    def create
      begin
        body = JSON.parse(request.body.read)
  
        required_fields = %w[projectId userId version type change changeReason revisionDate approvalDate approvedBy createdBy]
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
  
        version = Version.new(
            projectId: body['projectId'],
            version: body['version'],
            changeType: body['type'],
            change: body['change'],
            changeReason: body['changeReason'],
            createdBy: body['createdBy'],
            revisionDate: body['revisionDate'],
            approvalDate: body['approvalDate'],
            approvedBy: body['approvedBy']
        )
        version.save!
  
        render json: version, status: :created
      rescue => error
        render json: { error: error.message }, status: :internal_server_error
      end
    end


  
    def update
      begin
        body = JSON.parse(request.body.read)
        version = Version.find_by(id: params[:id])
        return render json: { error: "Version not found" }, status: :not_found unless version
  
        user = User.find_by(id: body['userId'])
        return render json: { error: "User not found" }, status: :not_found unless user
  
        unless ["ADMIN", "MANAGER"].include?(user.role)
          return render json: { error: "You don't have the necessary permissions" }, status: :forbidden
        end
  
        version.update!(
            version: body['version'],
            changeType: body['type'],
            change: body['change'],
            createdBy: body['createdBy'],
            changeReason: body['changeReason'],
            revisionDate: body['revisionDate'],
            approvalDate: body['approvalDate'],
            approvedBy: body['approvedBy']
        )
  
        render json: version, status: :ok
      rescue => error
        render json: { error: error.message }, status: :internal_server_error
      end
    end


    def destroy
        begin
          body = JSON.parse(request.body.read)
          version = Version.find_by(id: params[:id])
          return render json: { error: "Version not found" }, status: :not_found unless version
    
          user = User.find_by(id: body['userId'])
          return render json: { error: "User not found" }, status: :not_found unless user
    
          unless ["ADMIN", "MANAGER"].include?(user.role)
            return render json: { error: "You don't have the necessary permissions" }, status: :forbidden
          end
    
          version.destroy
    
          render json: { message: "Version deleted successfully" }, status: :ok
        rescue => error
          render json: { error: error.message }, status: :internal_server_error
        end
      end
  end
  