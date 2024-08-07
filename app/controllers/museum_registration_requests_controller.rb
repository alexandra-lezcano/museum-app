class MuseumRegistrationRequestsController < ApplicationController
  before_action :set_museum_registration_request, only: %i[ show ]
  skip_before_action :authenticate_user!, only: %i[ new create cities ]
  skip_before_action :authorize_user!, only: %i[ new create index cities ]

  # GET /museum_registration_requests or /museum_registration_requests.json
  def index
    # to-do: should review logic for showing or hiding items, also, should review the option to show or hide registration requests from non-admin creators
    if current_user.admin?
      @museum_registration_requests = MuseumRegistrationRequest.where.not(registration_status: MuseumRegistrationRequest::ARCHIVED)
    else
      @museum_registration_requests = MuseumRegistrationRequest.where(created_by_id: current_user.id)
    end

  end

  # GET /museum_registration_requests/1 or /museum_registration_requests/1.json
  def show
  end

  # GET /museum_registration_requests/new
  def new
    @museum_registration_request = MuseumRegistrationRequest.new
    @cities = City.all
    @departments = Department.order(:name).map{ |department| [department.name, department.id]}
  end

  # POST /museum_registration_requests or /museum_registration_requests.json
  def create
    @museum_registration_request = MuseumRegistrationRequest.new(museum_registration_request_params)

    if current_user
      @museum_registration_request.created_by = current_user
      @museum_registration_request.manager_email = current_user.email
      @museum_registration_request.first_name = current_user.first_name
      @museum_registration_request.last_name = current_user.last_name
      @museum_registration_request.ci = current_user.ci
      @museum_registration_request.phone_number = current_user.phone_number
    end

    respond_to do |format|
      if @museum_registration_request.save
        format.html { redirect_to root_path, notice: t(".success") }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update_registration_status
    @museum_registration_request = MuseumRegistrationRequest.find(params[:id])
    status = params[:registration_status].to_i

    begin
      message = @museum_registration_request.update_registration_status!(status, current_user) ?
                  t(".success", status: t("activerecord.attributes.museum_registration_request.registration_statuses.#{@museum_registration_request.registration_status}"))
                  : t(".failure")
      redirect_to @museum_registration_request, notice: message

    rescue StandardError => e # todo add more classes
      redirect_to @museum_registration_request, alert: e.message
    end
  end

  def cities
    # set a "target" this will contain the id of the html tag we want to update
    # this function will be connected with cities.turbo_stream.erb passing the @target and @cities attributes
    @target = params[:target]
    @department = Department.find(params[:department])
    @cities = @department.cities.order(:name).map{ |city| [city.name, city.id]}
    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_museum_registration_request
    @museum_registration_request = MuseumRegistrationRequest.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def museum_registration_request_params
    params.require(:museum_registration_request).permit(:museum_name, :museum_code, :museum_address, :manager_email, :department_id, :city_id, :registration_doc, :first_name, :last_name, :ci, :phone_number)
  end

  def get_archived
    @museum_registration_requests = MuseumRegistrationRequest.where(registration_status: MuseumRegistrationRequest::ARCHIVED)
  end

  def authorize_user!
    autorized = case action_name
                when "update_registration_status", "show", "archived" then current_user.admin?
                else
                  false
                end

    not_authorized unless autorized
  end
end
