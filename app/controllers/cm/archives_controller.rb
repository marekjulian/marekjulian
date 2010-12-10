class Cm::ArchivesController < ApplicationController

  before_filter :login_required

  layout "cm/cm"

  # GET /archives
  # GET /archives.xml
  def index
    logger.debug "cm/archives/index - session_id: #{request.session_options[:id]}"
    @archives = @current_user.archives

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @archives }
    end
  end

  def show
    logger.debug "cm/archives/index - session_id: #{request.session_options[:id]}"
    @archive = Archive.find( params[:id] )
    @collections = @archive.collections
    @portfolios = @archive.portfolios

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @archive }
    end
  end

  # GET /archives/new
  # GET /archives/new.xml
  def new
    @archive = Archive.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @archive }
    end
  end

  # GET /archives/1/edit
  def edit
    @archive = Archive.find( params[:id] )
    @collections = @archive.collections
    @portfolios = @archive.portfolios
  end

  # POST /archives
  # POST /archives.xml
  def create
    @archive = Archive.new(params[:archive])

    respond_to do |format|
      if @archive.save
        flash[:notice] = 'Archive was successfully created.'
        format.html { redirect_to(@archive) }
        format.xml  { render :xml => @archive, :status => :created, :location => @archive }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @archive.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /archives/1
  # PUT /archives/1.xml
  def update
    @archive = Archive.find(params[:id])

    respond_to do |format|
      if @archive.update_attributes(params[:archive])
        flash[:notice] = 'Archive was successfully updated.'
        format.html { redirect_to(@archive) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @archive.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /archives/1
  # DELETE /archives/1.xml
  def destroy
    @archive = Archive.find(params[:id])
    @archive.destroy

    respond_to do |format|
      format.html { redirect_to(archives_url) }
      format.xml  { head :ok }
    end
  end
end
