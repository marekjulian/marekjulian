class Cm::CollectionsController < ApplicationController

  before_filter :login_required
  layout "cm"

  # GET /cm/archive/:archive_id/collections
  # GET /cm/archive/:archive_id/collections.xml
  def index
    @collections = Cm::Collection.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cm_collections }
    end
  end

  # GET /cm/archive/:archive_id/collections/1
  # GET /cm/archive/:archive_id/collections/1.xml
  def show
    @archive = Cm::Archive.find( params[:archive_id] )
    @collection = Cm::Collection.find( params[:id] )

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @collection }
    end
  end

  # GET /cm/archive/:archive_id/collections/new
  # GET /cm/archive/:archive_id/collections/new.xml
  def new
    @collection = Cm::Collection.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @collection }
    end
  end

  # GET /cm_collections/1/edit
  def edit
    @archive = Cm::Archive.find( params[:archive_id] )
    @collection = Cm::Collection.find(params[:id])
  end

  # POST /cm_collections
  # POST /cm_collections.xml
  def create
    @collection = Cm::Collection.new(params[:collection])

    respond_to do |format|
      if @collection.save
        flash[:notice] = 'Cm::Collection was successfully created.'
        format.html { redirect_to(@collection) }
        format.xml  { render :xml => @collection, :status => :created, :location => @collection }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @collection.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /cm_collections/1
  # PUT /cm_collections/1.xml
  def update
    @collection = Cm::Collection.find(params[:id])

    respond_to do |format|
      if @collection.update_attributes(params[:collection])
        flash[:notice] = 'Cm::Collection was successfully updated.'
        format.html { redirect_to(@collection) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @collection.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /cm_collections/1
  # DELETE /cm_collections/1.xml
  def destroy
    @collection = Cm::Collection.find(params[:id])
    @collection.destroy

    respond_to do |format|
      format.html { redirect_to(cm_collections_url) }
      format.xml  { head :ok }
    end
  end
end
