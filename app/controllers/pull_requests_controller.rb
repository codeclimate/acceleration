class PullRequestsController < ApplicationController
  def index
    authenticate_user!

    @pull_requests = PullRequests

    @pull_requests = @pull_requests.tagged_with(params[:tag]) if params[:tag].present?

    @pull_requests = @pull_requests.order(created_at: :desc).offset(params[:offset] || 0).limit(params[:limit] || 20)

    # We only want pull requests owned by this user and that have been open for less than a week
    @output = []
    @output2 = []
    @pull_requests.each do |pr|
      if pr.author == current_user
        @output << pr
      end
    end

    @output.each do |pr|
      if pr.created_at - Time.now > 7
        @output2 << pr
      end
    end

    @pull_requests = output

    render :index
  end

  def create
    authenticate_user!

    @pull_request = PullRequest.new(params)
    @pull_request.user = current_user

    if @pull_request.save
      render :show
    else
      render json: { errors: @article.errors }, status: :unprocessable_entity
    end
  end

  def show
    authenticate_user!
    @pull_request = PullRequest.find_by_id!(params[:id])
  end

  def destroy
    @pull_request = PullRequest.find(params[:id])
    pull_request.destroy
    render json: {}
  end

  private
end
