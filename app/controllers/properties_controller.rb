class PropertiesController < ApplicationController
  before_action :set_property, only: [:show, :edit, :update, :destroy]

  # GET /properties
  # GET /properties.json
  def index
    @properties = Property.all

    respond_to do |format|
      format.html 
      format.json { render json: Property.to_json }
      format.n3 { render text: Property.to_n3, mime_type: "text/rdf+n3" }
      format.ttl { render text: Property.to_n3, mime_type: "application/x-turtle" }
      format.xml { render text: Property.to_xml, mime_type: "application/rdf+xml" }
    end
  end

  # GET /properties/1
  # GET /properties/1.json
  def show
    respond_to do |format|
      if @property.use_xslt?
        format.html { render inline: "<%= raw @property.to_xml %>  <%= raw @property.transform %>" }
      else
        format.html
      end
      format.json { render json: @property.to_json }
      format.n3 { render text: @property.to_n3, mime_type: "text/rdf+n3" }
      format.ttl { render text: @property.to_n3, mime_type: "application/x-turtle" }
      format.xml { render text: @property.to_xml, mime_type: "application/rdf+xml" }
    end
  end

  # GET /properties/new
  def new
    @property = Property.new
    @property.rdf = @property.turtle_prefixes.map{|k,v|
      "@prefix #{k}: <#{v}> ."
    }.join("\n") + "\n"
  end

  # GET /properties/1/edit
  def edit
  end

  # POST /properties
  # POST /properties.json
  def create
    @property = Property.new(property_params)

    respond_to do |format|
      if @property.save
        format.html { redirect_to @property, notice: 'Property was successfully created.' }
        format.json { render action: 'show', status: :created, location: @property }
      else
        format.html { render action: 'new' }
        format.json { render json: @property.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /properties/1
  # PATCH/PUT /properties/1.json
  def update
    respond_to do |format|
      if @property.update(property_params)
        format.html { redirect_to @property, notice: 'Property was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @property.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /properties/1
  # DELETE /properties/1.json
  def destroy
    @property.destroy
    respond_to do |format|
      format.html { redirect_to properties_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_property
      if prop = Integer(params[:id]) rescue nil
        @property = Property.find(prop)
      else
        @property = Property.find_by_name(params[:id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def property_params
      params.require(:property).permit(:name, :rdf, :xslt, :use_xslt)
    end
end
