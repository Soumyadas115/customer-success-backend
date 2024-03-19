class MomsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    begin
      body = JSON.parse(request.body.read)
      
      required_fields = %w[projectId userId duration date link comments]

      if required_fields.any? { |field| body[field].blank? }
        return render json: { error: 'Missing required fields' }, status: :bad_request
      end

      user = User.find_by(id: body['userId'])
      return render json: { error: "User not found" }, status: :not_found unless user

      unless ["ADMIN", "MANAGER"].include?(user.role)
        render json: { error: "You don't have the required permissions" }, status: :forbidden and return
      end

      project = Project.find_by(id: body['projectId'])
      return render json: { error: "Project not found" }, status: :not_found unless project

      mom = Mom.create!(
        date: body['date'],
        duration: body['duration'].to_i,
        link: body['link'],
        comments: body['comments'],
        projectId: body['projectId']
      )

      render json: stakeholder, status: :created
    rescue => error
      render json: { error: error.message }, status: :internal_server_error
    end
  end

  def update
    begin
      body = JSON.parse(request.body.read)

      mom = Mom.find_by(id: params[:id])
      return render json: { error: "Mom not found" }, status: :not_found unless mom

      user = User.find_by(id: body['userId'])
      return render json: { error: "User not found" }, status: :not_found unless user

      unless ["ADMIN", "MANAGER"].include?(user.role)
        render json: { error: "You don't have the required permissions" }, status: :forbidden and return
      end

      mom.update!(
        date: body['date'],
        duration: body['duration'].to_i,
        link: body['link'],
        comments: body['comments'],
      )

      render json: mom, status: :ok
    rescue => error
      render json: { error: error.message }, status: :internal_server_error
    end
  end


  def destroy
    Mom.transaction do
        body = JSON.parse(request.body.read)

        momId = params[:id]

        user = User.find_by(id: body['userId'])
        return render json: { error: "User not found" }, status: :not_found unless user

        unless user.role == "ADMIN" || user.role == "MANAGER"
        return render json: { error: "Insufficient permissions" }, status: :forbidden
        end
    
        mom = Mom.find_by(id: params[:id])

        unless mom
        return render json: { error: "Mom not found" }, status: :not_found
        end
    
        mom.destroy

        render json: { message: "Mom deleted successfully" }, status: :ok
    rescue => error
        render json: { error: error.message }, status: :internal_server_error
    end
  end
end
