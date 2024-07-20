class PieceCollectionsController < ApplicationController
  prepend_before_action :set_museum, only: %i[ index new create ]
  prepend_before_action :set_piece_collection, only: %i[ show edit update destroy update_status ]
  skip_before_action :authenticate_user!, only: %i[ index show ]
  skip_before_action :authorize_user!, only: %i[ index show ]

  # GET /piece_collections or /piece_collections.json
  def index
    @piece_collections = @museum.piece_collections
  end

  # GET /piece_collections/1 or /piece_collections/1.json
  def show
    @pieces = @piece_collection.pieces
  end

  # GET /piece_collections/new
  def new
    @piece_collection = @museum.piece_collections.build
  end

  # GET /piece_collections/1/edit
  def edit
  end

  # POST /piece_collections or /piece_collections.json
  def create
    @piece_collection = @museum.piece_collections.build(piece_collection_params)

    respond_to do |format|
      if @piece_collection.save
        format.html { redirect_to museum_piece_collections_path(@museum), notice: t(".success") }
        format.turbo_stream { flash.now[:notice] = t(".success") }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /piece_collections/1 or /piece_collections/1.json
  def update
    respond_to do |format|
      if @piece_collection.update(piece_collection_params)
        format.html { redirect_to piece_collection_url(@piece_collection), notice: t(".success")  }
        format.json { render :show, status: :ok, location: @piece_collection }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @piece_collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # TODO improve the redirect ! will only allow deleting from the collection page and redirect to the museum page
  # DELETE /piece_collections/1 or /piece_collections/1.json
  def destroy
    @piece_collection.destroy!

    respond_to do |format|
      format.html { redirect_to piece_collection_url, notice: "Piece collection was successfully destroyed." }
    end
  end

  def update_status
    status = params[:status].to_i

    begin
      message = @piece_collection.update_status!(status) ?
                  t(".success") : t(".error")
      redirect_to @piece_collection, notice: message

      # TODO handle exceptions with custom class
    rescue StandardError => e
      redirect_to @piece_collection, alert: e.message
    end
  end

  private

  def set_museum
    @museum = Museum.find(params[:museum_id])
  end

  def set_piece_collection
    @piece_collection = PieceCollection.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def piece_collection_params
    params.require(:piece_collection).permit(:name, :status, :is_permanent, :museum_id)
  end

  def authorize_user!
    museum = @museum ? @museum : @piece_collection.museum
    authorized = case action_name
                 when "destroy" then current_user.admin?
                 when "new", "create", "update", "edit", "update_status" then current_user.admin_or_museum_owner?(museum)
                 else
                   false
                 end

    not_authorized unless authorized
  end
end
