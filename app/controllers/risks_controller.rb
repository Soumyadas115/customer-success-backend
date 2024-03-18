class RisksController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    def create
      begin
        body = JSON.parse(request.body.read)
  
        required_fields = %w[projectId userId type description severity impact remedial status closureDate]
        if required_fields.any? { |field| body[field].blank? }
          render json: { error: "Missing required fields" }, status: :bad_request and return
        end
  
        user = User.find_by(id: body['userId'])
        return render json: { error: "User not found" }, status: :not_found unless user
  
        unless ["ADMIN", "MANAGER"].include?(user.role)
          return render json: { error: "You don't have the necessary permissions" }, status: :forbidden
        end
  
        project = Project.find_by(id: body['projectId'])
        return render json: { error: "Project not found" }, status: :not_found unless project
  
        risk = Risk.new(
          type: body['type'],
          description: body['description'],
          severity: body['severity'],
          impact: body['impact'],
          remedialSteps: body['remedial'],
          status: body['status'],
          closureDate: body['closureDate'],
          projectId: project.id
        )
        risk.save!
  
        render json: risk, status: :created
      rescue => error
        render json: { error: error.message }, status: :internal_server_error
      end
    end
  
    def update
      begin
        body = JSON.parse(request.body.read)
        risk = Risk.find_by(id: params[:id])
        return render json: { error: "Risk details not found" }, status: :not_found unless risk
  
        user = User.find_by(id: body['userId'])
        return render json: { error: "User not found" }, status: :not_found unless user
  
        unless ["ADMIN", "MANAGER"].include?(user.role)
          return render json: { error: "You don't have the necessary permissions" }, status: :forbidden
        end
  
        risk.update!(
          type: body['type'],
          description: body['description'],
          severity: body['severity'],
          impact: body['impact'],
          remedialSteps: body['remedial'],
          status: body['status'],
          closureDate: body['closureDate']
        )
  
        render json: risk, status: :ok
      rescue => error
        render json: { error: error.message }, status: :internal_server_error
      end
    end

    def destroy
        Risk.transaction do
          body = JSON.parse(request.body.read)
          riskId = params[:id]
    
          user = User.find_by(id: body['userId'])
          return render json: { error: "User not found" }, status: :not_found unless user
    
          unless user.role == "ADMIN" || user.role == "MANAGER"
            return render json: { error: "Insufficient permissions" }, status: :forbidden
          end
      
          risk = Risk.find_by(id: params[:id])
    
          unless risk
            return render json: { error: "Risk not found" }, status: :not_found
          end
      
          risk.destroy
    
          render json: { message: "Risk deleted successfully" }, status: :ok
        rescue => error
          render json: { error: error.message }, status: :internal_server_error
        end
      end
  end
  