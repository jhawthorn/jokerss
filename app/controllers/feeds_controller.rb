class FeedsController < ApplicationController
  before_action :set_feed, only: %i[ show edit update destroy refresh ]

  # GET /feeds or /feeds.json
  def index
    @feeds = Prelude.wrap(Feed.all.to_a)
    @feeds = @feeds.sort_by(&:last_published).reverse
  end

  def timeline
    @feeds = Feed.all
    @entries = Entry.where(feed: @feeds).order(published: :desc).limit(10)
  end

  # GET /feeds/1 or /feeds/1.json
  def show
  end

  # GET /feeds/new
  def new
    @feed = Feed.new
  end

  # GET /feeds/1/edit
  def edit
  end

  # POST /feeds/1/refresh
  def refresh
    RefreshJob.perform_now(@feed)
    redirect_back fallback_location: @feed
  end

  # POST /feeds/refresh
  def refresh_all
    @feeds = Feed.all
    @feeds.each do |feed|
      RefreshJob.perform_later(feed)
    end
    redirect_back fallback_location: feeds_path
  end


  # POST /feeds or /feeds.json
  def create
    @feed = Feed.new(feed_params)

    respond_to do |format|
      if @feed.save
        format.html { redirect_to @feed, notice: "Feed was successfully created." }
        format.json { render :show, status: :created, location: @feed }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /feeds/1 or /feeds/1.json
  def update
    respond_to do |format|
      if @feed.update(feed_params)
        format.html { redirect_to @feed, notice: "Feed was successfully updated." }
        format.json { render :show, status: :ok, location: @feed }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /feeds/1 or /feeds/1.json
  def destroy
    @feed.destroy
    respond_to do |format|
      format.html { redirect_to feeds_url, notice: "Feed was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feed
      @feed = Feed.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def feed_params
      params.require(:feed).permit(:title, :fetch_url, :homepage_url)
    end
end
