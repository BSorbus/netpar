class DocumentsController < ApplicationController
  before_action :authenticate_user!
  #after_action :verify_authorized, except: [:index, :datatables_index, :datatables_index_exam]


  include  ActionView::Helpers::NumberHelper

  def show
    @document = Document.find(params[:id])
    file = @document.fileattach.read

    send_data file, 
      filename: @document.fileattach_filename,
      type: @document.fileattach_content_type, 
      disposition: "attachment"              

    @document.works.create!(trackable_url: "#{document_path(@document)}", action: :download, user: current_user, parameters: @document.attributes.to_json)
  end

  def create
    @document = @documentable.documents.new(document_params)

    respond_to do |format|
      if @document.save
        @document.works.create!(trackable_url: "#{document_path(@document)}", action: :upload, user: current_user, parameters: @document.attributes.to_json)

        flash_message :success, t('activerecord.messages.successfull.attach_file', parent: @document.documentable.fullname, 
          child: "#{@document.fileattach_filename} (#{number_to_human_size(@document.fileattach_size)})")
        format.html { redirect_to :back }
      else
        flash_message :error, t('activerecord.messages.error.attach_file', parent: @document.documentable.fullname, 
          child: "#{@document.fileattach_filename} (#{number_to_human_size(@document.fileattach_size)})")
        format.html { redirect_to :back }
      end
    end

#    #authorize @department, :create?
#
#    respond_to do |format|
#      if @department.save
#        format.html { redirect_to @department, notice: t('activerecord.messages.successfull.created', data: @department.short) }
#        format.json { render :show, status: :created, location: @department }
#      else
#        format.html { render :new }
#        format.json { render json: @department.errors, status: :unprocessable_entity }
#      end
#    end
  end

  def destroy
    @document = Document.find(params[:id])
    if @document.destroy
      Work.create!(trackable: @document, action: :destroy, user: current_user, parameters: @document.attributes.to_json)

      flash_message :success, t('activerecord.messages.successfull.remove_attach_file', parent: @document.documentable.fullname, child: @document.fileattach_filename) 
      redirect_to :back
    else 
      flash_message :error, t('activerecord.messages.error.destroyed', data: @document.fileattach_filename) 
      redirect_to :back
      #render :show
    end      
  end

  private

    def document_params
      params.require(:document).permit(:fileattach, :remote_fileattach_url, :remove_fileattach)
    end


end