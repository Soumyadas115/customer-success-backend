class StakeholdersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    begin
      body = JSON.parse(request.body.read)
      
      required_fields = %w[projectId title name contact userId]

      if required_fields.any? { |field| body[field].blank? }
        render json: { error: "Missing required fields" }, status: :bad_request and return
      end

      user = User.find_by(id: body['userId'])
      return render json: { error: "User not found" }, status: :not_found unless user

      unless ["ADMIN", "AUDITOR"].include?(user.role)
        render json: { error: "You don't have the required permissions" }, status: :forbidden and return
      end

      project = Project.find_by(id: body['projectId'])
      return render json: { error: "Project not found" }, status: :not_found unless project

      stakeholder = Stakeholder.create!(
        title: body['title'],
        name: body['name'],
        contact: body['contact'],
        projectId: project.id
      )

      render json: stakeholder, status: :created
    rescue => error
      render json: { error: error.message }, status: :internal_server_error
    end
  end

  def update
    begin
      body = JSON.parse(request.body.read)

      stakeholder = Stakeholder.find_by(id: params[:id])
      return render json: { error: "Stakeholder not found" }, status: :not_found unless stakeholder

      user = User.find_by(id: body['userId'])
      return render json: { error: "User not found" }, status: :not_found unless user

      unless ["ADMIN", "AUDITOR"].include?(user.role)
        render json: { error: "You don't have the required permissions" }, status: :forbidden and return
      end

      stakeholder.update!(
        title: body['title'],
        name: body['name'],
        contact: body['contact']
      )

      render json: stakeholder, status: :ok
    rescue => error
      render json: { error: error.message }, status: :internal_server_error
    end
  end


  def destroy
    Stakeholder.transaction do
        body = JSON.parse(request.body.read)

        stakeholderId = params[:id]

        user = User.find_by(id: body['userId'])
        return render json: { error: "User not found" }, status: :not_found unless user

        unless user.role == "ADMIN" || user.role == "AUDITOR"
        return render json: { error: "Insufficient permissions" }, status: :forbidden
        end
    
        stakeholder = Stakeholder.find_by(id: params[:id])

        unless stakeholder
        return render json: { error: "Stakeholder not found" }, status: :not_found
        end
    
        stakeholder.destroy

        render json: { message: "Stakeholder deleted successfully" }, status: :ok
    rescue => error
        render json: { error: error.message }, status: :internal_server_error
    end
  end
end
