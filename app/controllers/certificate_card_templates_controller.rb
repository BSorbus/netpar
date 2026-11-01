# Wzory kart plastikowych świadectw (HID FARGO HDP6600) – jak stawki opłat: lista, podgląd, dodanie, edycja, usunięcie.
class CertificateCardTemplatesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:datatables_index]

  before_action :set_certificate_card_template, only: [:show, :edit, :update, :destroy, :layout, :update_layout, :preview]

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

  # Układ nadruku: karta (awers/rewers) z prostokątami pól i lista atrybutów z „ptaszkiem” i współrzędnymi w mm.
  def layout
    authorize @certificate_card_template, :edit?
    @fields = layout_fields
  end

  def update_layout
    authorize @certificate_card_template, :update?
    if @certificate_card_template.update(fields_attributes: layout_params)
      @certificate_card_template.works.create!(trackable_url: certificate_card_template_path(@certificate_card_template), action: :update_layout,
                                               user: current_user, parameters: layout_snapshot.to_json)
      flash_message :success, t('activerecord.messages.successfull.updated', data: @certificate_card_template.fullname)
      redirect_to layout_certificate_card_template_path(@certificate_card_template)
    else
      @fields = layout_fields
      render :layout
    end
  end

  # Podgląd wydruku karty (awers i rewers) z przykładowymi danymi – przed pierwszym prawdziwym wydrukiem.
  def preview
    authorize @certificate_card_template, :show?
    pdf = PdfCertificateCard.new([[CertificateCardData.sample(@certificate_card_template.division), @certificate_card_template]],
                                 "#{current_user.name} (#{current_user.email})", "Podgląd karty – #{@certificate_card_template.name}")
    send_data pdf.render, filename: "Karta_podglad_#{@certificate_card_template.id}.pdf", type: 'application/pdf', disposition: 'inline'
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

    # Wszystkie atrybuty w kolejności katalogu: zapisane pola wzoru i (niezaznaczone) propozycje dla pozostałych.
    def layout_fields
      CertificateCardTemplateField::ATTRIBUTES.map do |name|
        @certificate_card_template.fields.detect { |field| field.attribute_name == name } ||
          @certificate_card_template.fields.build(attribute_name: name, side: 'front', x: 5, y: 5, width: name == 'photo' ? 20 : 40,
                                                  height: name == 'photo' ? 25 : 6, font_size: 10, enabled: false)
      end
    end

    # Niezaznaczone zapisane pola – do usunięcia; niezaznaczone nowe – pomijane (reject_if w modelu).
    def layout_params
      fields = params.require(:certificate_card_template).fetch(:fields_attributes, {})
      fields.keys.map do |key| # fields[key] – Parameters (values w Rails 4.2 zwraca zwykłe hashe)
        permitted = fields[key].permit(:id, :enabled, :attribute_name, :side, :x, :y, :width, :height, :font_size, :bold, :align, :color)
        permitted[:_destroy] = '1' if permitted[:id].present? && permitted[:enabled] != '1'
        permitted
      end
    end

    def layout_snapshot
      @certificate_card_template.fields.reload.map do |f|
        f.attributes.slice('attribute_name', 'side', 'x', 'y', 'width', 'height', 'font_size', 'bold', 'align', 'color')
      end
    end

    def certificate_card_template_params
      params.require(:certificate_card_template).permit(:division_id, :name, :valid_from, :valid_to,
                                                        :card_front, :remove_card_front, :card_back, :remove_card_back)
    end
end
