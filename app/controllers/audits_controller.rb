class AuditsController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    def create
      Audit.transaction do
        body = JSON.parse(request.body.read)
  
        required_fields = %w[projectId userId date comments reviewedBy reviewedSection status actionItem]
        if required_fields.any? { |field| body[field].blank? }
          render json: { error: "Missing required fields" }, status: :bad_request and return
        end
  
        user = User.find_by(id: body['userId'])
        return render json: { error: "User not found" }, status: :not_found unless user
  
        unless user.role == "ADMIN" || user.role == "AUDITOR"
          return render json: { error: "Insufficient permissions" }, status: :forbidden
        end
  
        project = Project.find_by(id: body['projectId'])
        return render json: { error: "Project not found" }, status: :not_found unless project
  
        audit = Audit.new(
          date: body['date'],
          comments: body['comments'],
          reviewedBy: body['reviewedBy'],
          reviewedSection: body['reviewedSection'],
          status: body['status'],
          actionItem: body['actionItem'],
          projectId: project.id,
        )
        audit.save!
      end
      render json: { message: "Audit created successfully" }, status: :created
    rescue => error
      render json: { error: error.message }, status: :internal_server_error
    end



    def update
        audit = Audit.find_by(id: params[:id])
        return render json: { error: "Audit not found" }, status: :not_found unless audit
    
        body = JSON.parse(request.body.read)
        user = User.find_by(id: body['userId'])
        return render json: { error: "User not found" }, status: :not_found unless user
  
        unless user.role == "ADMIN" || user.role == "AUDITOR"
          return render json: { error: "Insufficient permissions" }, status: :forbidden
        end
    
        audit.date = Date.parse(body['date']) if body['date']
        audit.comments = body['comments'] if body['comments']
        audit.reviewedBy = body['reviewedBy'] if body['reviewedBy']
        audit.reviewedSection = body['reviewedSection'] if body['reviewedSection']
        audit.status = body['status'] if body['status']
        audit.actionItem = body['actionItem'] if body['actionItem']
    
        if audit.save
          render json: { message: "Audit updated successfully" }, status: :ok
        else
          render json: { error: audit.errors.full_messages.join(', ') }, status: :unprocessable_entity
        end
    rescue => error
    render json: { error: error.message }, status: :internal_server_error
    end

    def destroy
        Audit.transaction do
          body = JSON.parse(request.body.read)
          auditId = params[:id]
    
          user = User.find_by(id: body['userId'])
          return render json: { error: "User not found" }, status: :not_found unless user
    
          unless user.role == "ADMIN" || user.role == "AUDITOR"
            return render json: { error: "Insufficient permissions" }, status: :forbidden
          end
      
          audit = Audit.find_by(id: params[:id])
    
          unless audit
            return render json: { error: "Audit not found" }, status: :not_found
          end
      
          audit.destroy
    
          render json: { message: "Audit deleted successfully" }, status: :ok
        rescue => error
          render json: { error: error.message }, status: :internal_server_error
        end
      end

    
end