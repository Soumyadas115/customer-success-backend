class AuditsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    begin
      body = JSON.parse(request.body.read)

      required_fields = %w[projectId userId date comments reviewedBy reviewedSection status  actionItem]
      if required_fields.any? { |field| body[field].blank? }
          return render json: { error: 'Missing required fields' }, status: :bad_request
      end

      user = User.find_by(id: body['userId'])
      return render json: { error: "User not found" }, status: :not_found unless user

      unless ["ADMIN", "AUDITOR"].include?(user.role)
        return render json: { error: "You don't have the necessary permissions" }, status: :forbidden
      end

      project = Project.find_by(id: body['projectId'])
      return render json: { error: "Project not found" }, status: :not_found unless project

      audit = Audit.new(
          projectId: body['projectId'],
          date: body['date'],
          comments: body['comments'],
          reviewedBy: body['reviewedBy'],
          reviewedSection: body['reviewedSection'],
          status: body['status'],
          actionItem: body['actionItem'],
      )
      audit.save!

      render json: audit, status: :created
    rescue => error
      render json: { error: error.message }, status: :internal_server_error
    end
  end



  def update
    begin
      body = JSON.parse(request.body.read)
      audit = Audit.find_by(id: params[:id])
      return render json: { error: "Audit not found" }, status: :not_found unless audit

      user = User.find_by(id: body['userId'])
      return render json: { error: "User not found" }, status: :not_found unless user

      unless ["ADMIN", "AUDITOR"].include?(user.role)
        return render json: { error: "You don't have the necessary permissions" }, status: :forbidden
      end

      audit.update!(
        date: body['date'],
        comments: body['comments'],
        reviewedBy: body['reviewedBy'],
        reviewedSection: body['reviewedSection'],
        status: body['status'],
        actionItem: body['actionItem'],
      )

      render json: audit, status: :ok
    rescue => error
      render json: { error: error.message }, status: :internal_server_error
    end
  end


  def destroy
      begin
        body = JSON.parse(request.body.read)
        audit = Audit.find_by(id: params[:id])
        return render json: { error: "Audit not found" }, status: :not_found unless audit
  
        user = User.find_by(id: body['userId'])
        return render json: { error: "User not found" }, status: :not_found unless user
  
        unless ["ADMIN", "MANAGER"].include?(user.role)
          return render json: { error: "You don't have the necessary permissions" }, status: :forbidden
        end
  
        audit.destroy
  
        render json: { message: "Audit deleted successfully" }, status: :ok
      rescue => error
        render json: { error: error.message }, status: :internal_server_error
      end
    end
end
