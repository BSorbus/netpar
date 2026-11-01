require 'rails_helper'

# Wzory kart świadectw – własne role (certificate_card_template:*), niezależne od stawek opłat.
describe CertificateCardTemplatePolicy do
  subject { described_class }
  let(:user) { FactoryBot.create(:user) }

  def with_role(method)
    role = CreateRoleService.new.public_send(method)
    user.roles << role
    user
  end

  permissions :index?, :show?, :new?, :create?, :edit?, :update?, :destroy?, :work? do
    it 'bez ról – brak dostępu' do
      expect(subject).not_to permit(user, :certificate_card_template)
    end

    it 'Menadżer Wzorów Kart Świadectw – pełny dostęp' do
      expect(subject).to permit(with_role(:certificate_card_template_manager), :certificate_card_template)
    end
  end

  permissions :index?, :show? do
    it 'Obserwator Wzorów Kart Świadectw – lista i podgląd' do
      expect(subject).to permit(with_role(:certificate_card_template_observer), :certificate_card_template)
    end
  end

  permissions :new?, :edit?, :destroy?, :work? do
    it 'Obserwator Wzorów Kart Świadectw – bez zmian' do
      expect(subject).not_to permit(with_role(:certificate_card_template_observer), :certificate_card_template)
    end

    it 'Menadżer Stawek Opłat – bez dostępu do wzorów kart' do
      expect(subject).not_to permit(with_role(:exam_fee_manager), :certificate_card_template)
    end
  end
end
