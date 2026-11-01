# Wzory kart plastikowych świadectw – własne czynności certificate_card_template:* (role „Menadżer/Obserwator Wzorów Kart
# Świadectw”, CreateRoleService). Wydruk kart na sesji i świadectwie – wg uprawnień do wydruku świadectw.
class CertificateCardTemplatePolicy < ApplicationPolicy
  attr_reader :user, :model

  def initialize(user, model)
    @user = user
    @model = model
  end

  def index?
    user_activities.include? 'certificate_card_template:index'
  end

  # Także podgląd wydruku karty (PDF z danymi przykładowymi).
  def show?
    user_activities.include? 'certificate_card_template:show'
  end

  def new?
    user_activities.include? 'certificate_card_template:create'
  end

  def create?
    new?
  end

  # Także układ nadruku.
  def edit?
    user_activities.include? 'certificate_card_template:update'
  end

  def update?
    edit?
  end

  def destroy?
    user_activities.include? 'certificate_card_template:delete'
  end

  def work?
    user_activities.include? 'certificate_card_template:work'
  end

  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end
