class ProjectsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    begin
      body = JSON.parse(request.body.read)
      createdBy = body['createdBy']
      name = body['name']
      description = body['description']
      scope = body['scope']
      manager = body['manager']
      client = body['client']
      auditor = body['auditor']
      type = body['type']
      duration = body['duration']
      budgetedHours = body['budgetedHours']

      if [createdBy, name, description, scope, manager, client, auditor, type, duration, budgetedHours].any?(&:nil?)
        render json: { error: "Missing required fields" }, status: :bad_request
        return
      end

      user = User.find_by(id: createdBy)

      unless user
        render json: { error: "User with id #{createdBy} not found" }, status: :not_found
        return
      end

      project = Project.new(
        name: name,
        description: description,
        scope: scope,
        projectType: type,
        type: type,
        duration: duration,
        budgetedHours: budgetedHours,
        user: user
      )

      managerUser = User.find_by(email: manager)
      clientUser = User.find_by(email: client)
      auditorUser = User.find_by(email: auditor)

      project.projectManagerId = managerUser.id if managerUser
      project.clientId = clientUser.id if clientUser
      project.auditorId = auditorUser.id if auditorUser

      if project.save
        render json: project, status: :ok
      else
        render json: { error: project.errors.full_messages }, status: :unprocessable_entity
      end
    rescue => error
      render json: { error: error.message }, status: :internal_server_error
    end
  end

  # Other actions...
end
