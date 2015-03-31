class StreamsController < ApplicationController
  before_action :set_stream, only: [:show, :edit, :update, :destroy]

  def index
    @streams = Stream.all
  end

  def show
  end

  def new
    @stream = Stream.new
  end

  def edit
  end

  def create
    @stream = Stream.new params.require(:stream).permit(:name, :kind)
    respond_to do |format|
      if @stream.save
        format.html { redirect_to @stream, notice: 'Stream was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @stream.update(params.require(:stream).permit(:name))
        format.html { redirect_to @stream, notice: 'Stream was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @stream.destroy
    respond_to do |format|
      format.html { redirect_to streams_url, notice: 'Stream was successfully destroyed.' }
    end
  end


  private

  def set_stream
    @stream = Stream.find(params[:id])
  end
end
