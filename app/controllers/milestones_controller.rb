class MilestonesController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    def create
      Milestone.transaction do
        body = JSON.parse(request.body.read)
  
        required_fields = %w[projectId userId phase startDate completionDate approvalDate status revisedCompletionDate comments]
        if required_fields.any? { |field| body[field].blank? }
          render json: { error: "Missing required fields" }, status: :bad_request and return
        end
  
        user = User.find_by(id: body['userId'])
        return render json: { error: "User not found" }, status: :not_found unless user
  
        unless user.role == "ADMIN" || user.role == "MANAGER"
          return render json: { error: "Insufficient permissions" }, status: :forbidden
        end
  
        project = Project.find_by(id: body['projectId'])
        return render json: { error: "Project not found" }, status: :not_found unless project
  
        milestone = Milestone.new(
          title: body['phase'],
          startDate: body['startDate'],
          completionDate: body['completionDate'],
          approvalDate: body['approvalDate'],
          revisedCompletionDate: body['revisedCompletionDate'],
          comments: body['comments'],
          phase: body['phase'],
          status: body['status'],
          projectId: project.id,
        )
        milestone.save!
      end
      render json: { message: "Milestone created successfully" }, status: :created
    rescue => error
      render json: { error: error.message }, status: :internal_server_error
    end



    def update
        milestone = Milestone.find_by(id: params[:id])
        return render json: { error: "Milestone not found" }, status: :not_found unless milestone
    
        body = JSON.parse(request.body.read)
        user = User.find_by(id: body['userId'])
        return render json: { error: "User not found" }, status: :not_found unless user
  
        unless user.role == "ADMIN" || user.role == "MANAGER"
          return render json: { error: "Insufficient permissions" }, status: :forbidden
        end
    
        milestone.startDate = Date.parse(body['startDate']) if body['startDate']
        milestone.complpetionDate = Date.parse(body['complpetionDate']) if body['complpetionDate']
        milestone.approvalDate = Date.parse(body['approvalDate']) if body['approvalDate']
        milestone.revisedCompletionDate = Date.parse(body['revisedCompletionDate']) if body['revisedCompletionDate']
        milestone.comments = body['comments'] if body['comments']
        milestone.phase = body['phase'] if body['phase']
        milestone.status = body['status'] if body['status']
    
        if milestone.save
          render json: { message: "Milestone updated successfully" }, status: :ok
        else
          render json: { error: milestone.errors.full_messages.join(', ') }, status: :unprocessable_entity
        end
    rescue => error
    render json: { error: error.message }, status: :internal_server_error
    end

    def destroy
        Milestone.transaction do
          body = JSON.parse(request.body.read)
          milestoneId = params[:id]
    
          user = User.find_by(id: body['userId'])
          return render json: { error: "User not found" }, status: :not_found unless user
    
          unless user.role == "ADMIN" || user.role == "MANAGER"
            return render json: { error: "Insufficient permissions" }, status: :forbidden
          end
      
          milestone = Milestone.find_by(id: params[:id])
    
          unless milestone
            return render json: { error: "Milestone not found" }, status: :not_found
          end
      
          milestone.destroy
    
          render json: { message: "Milestone deleted successfully" }, status: :ok
        rescue => error
          render json: { error: error.message }, status: :internal_server_error
        end
      end

    
end