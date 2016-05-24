class Esod::Matters::IncomingLettersController < ApplicationController
  before_action :authenticate_user!
  #after_action :verify_authorized, except: [:index, :datatables_index]

  before_action :set_esod_incoming_letter, only: [:show]
  before_action :set_esod_matter, only: [:show]

  # GET /esod/incoming_letters/1
  # GET /esod/incoming_letters/1.json
  def show
    @esod_incoming_letter_matter = Esod::IncomingLettersMatter.find_by(esod_matter_id: @esod_matter.id, esod_incoming_letter_id: @esod_incoming_letter.id)

    exam_id = nil
    customer_id = nil
    certificate_id = nil

    respond_to do |format|
      format.json { render json: @esod_matter, root: false }
      format.html do

        category_service =
          if    Esodes::JRWA_L.include?(@esod_matter.symbol_jrwa.to_i)
            'l'
          elsif Esodes::JRWA_M.include?(@esod_matter.symbol_jrwa.to_i)
            'm'
          elsif Esodes::JRWA_R.include?(@esod_matter.symbol_jrwa.to_i)
            'r'
          else
            raise "Bad param symbol_jrwa: #{@esod_matter.symbol_jrwa}"
          end

        resource_service =
          if Esodes::ALL_CATEGORIES_EXAMS.include?(@esod_matter.identyfikator_kategorii_sprawy)
            'exam'
          elsif Esodes::ALL_CATEGORIES_EXAMINATIONS.include?(@esod_matter.identyfikator_kategorii_sprawy)
            'examination'
          elsif Esodes::ALL_CATEGORIES_CERTIFICATES.include?(@esod_matter.identyfikator_kategorii_sprawy)
            'certificate'
          else
            #raise "Bad param identyfikator_kategorii_sprawy: #{@esod_matter.identyfikator_kategorii_sprawy}"
            "Bad param identyfikator_kategorii_sprawy: #{@esod_matter.identyfikator_kategorii_sprawy}"
          end

        action_service =
          if Esodes::ACTION_NEW.include?(@esod_matter.identyfikator_kategorii_sprawy)
            'new'
          elsif Esodes::ACTION_EDIT.include?(@esod_matter.identyfikator_kategorii_sprawy)
            'edit'
          else
            raise "Bad param identyfikator_kategorii_sprawy: #{@esod_matter.identyfikator_kategorii_sprawy}"
            #{}"Bad param identyfikator_kategorii_sprawy: #{@esod_matter.identyfikator_kategorii_sprawy}"
          end

        if action_service == 'new'
          if resource_service != 'exam'
            customer_id = @esod_incoming_letter.esod_contractor.customer_id

            unless customer_id.present?
              customer = Customer.find_by(pesel: @esod_incoming_letter.esod_contractor.pesel) if @esod_incoming_letter.esod_contractor.pesel.present?
              customer_id = customer.id if customer.present? 
            end
            unless customer_id.present?
              customer = Customer.find_by(name: @esod_incoming_letter.esod_contractor.nazwisko.strip, given_names: @esod_incoming_letter.esod_contractor.imie.strip, address_city: @esod_incoming_letter.esod_address.miasto.strip )
              customer_id = customer.id if customer.present? 
            end

            exam = Exam.find_by(category: "#{category_service}".upcase, number: @esod_matter.esod_matter_notes.last.tytul.strip) if @esod_matter.esod_matter_notes.last.tytul.present?
            exam = Exam.find_by(category: "#{category_service}".upcase, number: @esod_matter.esod_matter_notes.last.tresc.strip) if @esod_matter.esod_matter_notes.last.tresc.present? && exam.blank?
            exam_id = exam.id if exam.present?
          end
        else
          if resource_service == 'certificate'
            certificate = Certificate.find_by(category: "#{category_service}".upcase, number: @esod_matter.esod_matter_notes.last.tytul)
            certificate = Certificate.find_by(category: "#{category_service}".upcase, number: @esod_matter.esod_matter_notes.last.tresc) unless certificate.present?
            certificate_id = certificate.id if certificate.present?
          end
        end

        #@esod_matter.save_to_esod(current_user.email, current_user.esod_encryped_password)
       
        render :show, locals: { category_service: category_service, resource_service: resource_service, action_service: action_service, customer_id: customer_id, exam_id: exam_id, certificate_id: certificate_id  } 
      end
    end 

  end

  def create
    incoming_create
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_esod_incoming_letter
      @esod_incoming_letter = Esod::IncomingLetter.find(params[:id])
    end

    def set_esod_matter
      @esod_matter = Esod::Matter.find(params[:matter_id])
    end

end
