class ProjectsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    Project.transaction do
      body = JSON.parse(request.body.read)
      
      required_fields = %w[createdBy name description scope manager client auditor type duration budgetedHours]
      if required_fields.any? { |field| body[field].blank? }
        render json: { error: "Missing required fields" }, status: :bad_request and return
      end

      creator = User.find_by(id: body['createdBy'])
      return render json: { error: "Creator not found" }, status: :not_found unless creator

      unless creator.role == "ADMIN" || creator.role == "AUDITOR"
        return render json: { error: "Insufficient permissions" }, status: :forbidden
      end

      project = Project.new(
        name: body['name'],
        description: body['description'],
        scope: body['scope'],
        projectType: body['type'],
        type: body['type'],
        duration: body['duration'],
        budgetedHours: body['budgetedHours'],
        userId: creator.id
      )


      manager = User.find_by(email: body['manager'])
      client = User.find_by(email: body['client'])
      auditor = User.find_by(email: body['auditor'])


      
      unless manager && client && auditor
        missing_roles = []
        missing_roles << 'manager' unless manager
        missing_roles << 'client' unless client
        missing_roles << 'auditor' unless auditor
        return render json: { error: "Missing users for roles: #{missing_roles.join(', ')}" }, status: :bad_request
      end

      if project.save
        Member.create!(project: project, user: creator, role: 'ADMIN', name: creator.name, imageUrl: creator.imageUrl)
        Member.create!(project: project, user: manager, role: 'MANAGER', name: manager.name, imageUrl: manager.imageUrl)
        Member.create!(project: project, user: client, role: 'CLIENT', name: client.name, imageUrl: client.imageUrl)
        Member.create!(project: project, user: auditor, role: 'AUDITOR', name: auditor.name, imageUrl: auditor.imageUrl)

        project.update!(
          projectManagerId: manager.id,
          clientId: client.id,
          auditorId: auditor.id
        )
        render json: project, status: :created
      else
        render json: { error: project.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
    rescue => error
      render json: { error: error.message }, status: :internal_server_error
    end
  end

  def update
    Project.transaction do
      body = JSON.parse(request.body.read)
      projectId = params[:id]
  
      project = Project.find_by(id: projectId)
      unless project
        return render json: { error: "Project not found" }, status: :not_found
      end
  
      updated_attributes = body.slice('userId', 'name', 'description', 'scope', 'type', 'duration', 'budgetedHours')

      user = User.find_by(id: body['userId'])
      return render json: { error: "Creator not found" }, status: :not_found unless user

      unless user.role == "ADMIN" || user.role == "AUDITOR"
        return render json: { error: "Insufficient permissions" }, status: :forbidden
      end
      
      if project.update(updated_attributes)
        render json: project, status: :ok
      else
        render json: { error: project.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
    rescue => error
      render json: { error: error.message }, status: :internal_server_error
    end
  end

  def destroy
    Project.transaction do
      body = JSON.parse(request.body.read)
      projectId = params[:id]

      user = User.find_by(id: body['userId'])
      return render json: { error: "User not found" }, status: :not_found unless user

      unless user.role == "ADMIN" || user.role == "AUDITOR"
        return render json: { error: "Insufficient permissions" }, status: :forbidden
      end
  
      project = Project.find_by(id: projectId)

      unless project
        return render json: { error: "Project not found" }, status: :not_found
      end
  
      project.destroy

      render json: { message: "Project deleted successfully" }, status: :ok
    rescue => error
      render json: { error: error.message }, status: :internal_server_error
    end
  end
  

  # Other actions...
end
