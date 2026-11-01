# Wzory kart plastikowych świadectw (HID FARGO HDP6600) – jak stawki opłat: lista, podgląd, dodanie, edycja, usunięcie.
class CertificateCardTemplatesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:datatables_index]

  before_action :set_certificate_card_template, only: [:show, :edit, :update, :destroy]

  def index
    authorize :certificate_card_template, :index?
  end

  def datatables_index
    templates = CertificateCardTemplate.includes(:division).all

    respond_to do |format|
      format.json { render json: templates, each_serializer: CertificateCardTemplateSerializer, root: 'data' }
    end
  end

  def show
    authorize @certificate_card_template, :show?
  end

  def new
    @certificate_card_template = CertificateCardTemplate.new(division_id: params[:division_id])
    authorize @certificate_card_template, :new?
  end

  def edit
    authorize @certificate_card_template, :edit?
  end

  def create
    @certificate_card_template = CertificateCardTemplate.new(certificate_card_template_params)
    @certificate_card_template.user = current_user
    authorize @certificate_card_template, :create?

    if @certificate_card_template.save
      @certificate_card_template.works.create!(trackable_url: certificate_card_template_path(@certificate_card_template), action: :create,
                                               user: current_user, parameters: @certificate_card_template.attributes.to_json)
      flash_message :success, t('activerecord.messages.successfull.created', data: @certificate_card_template.fullname)
      redirect_to @certificate_card_template
    else
      render :new
    end
  end

  def update
    authorize @certificate_card_template, :update?
    @certificate_card_template.user = current_user

    if @certificate_card_template.update(certificate_card_template_params)
      @certificate_card_template.works.create!(trackable_url: certificate_card_template_path(@certificate_card_template), action: :update,
                                               user: current_user, parameters: @certificate_card_template.previous_changes.to_json)
      flash_message :success, t('activerecord.messages.successfull.updated', data: @certificate_card_template.fullname)
      redirect_to @certificate_card_template
    else
      render :edit
    end
  end

  def destroy
    authorize @certificate_card_template, :destroy?

    if @certificate_card_template.destroy
      Work.create!(trackable: @certificate_card_template, action: :destroy, user: current_user,
                   parameters: @certificate_card_template.attributes.to_json)
      flash_message :success, t('activerecord.messages.successfull.destroyed', data: @certificate_card_template.fullname)
      redirect_to certificate_card_templates_url
    else
      flash_message :error, @certificate_card_template.errors.full_messages.join(' ')
      render :show
    end
  end

  private
    def set_certificate_card_template
      @certificate_card_template = CertificateCardTemplate.find(params[:id])
    end

    def certificate_card_template_params
      params.require(:certificate_card_template).permit(:division_id, :name, :valid_from, :valid_to,
                                                        :card_front, :remove_card_front, :card_back, :remove_card_back)
    end
end
