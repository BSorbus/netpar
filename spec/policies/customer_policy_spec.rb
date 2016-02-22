require 'rails_helper'

describe CustomerPolicy do

  let(:customer) { FactoryGirl.build(:customer) }
  let(:user) { FactoryGirl.create(:user) }

  subject { described_class }

  context 'when user without roles' do
    permissions :index? do
      it 'denies access "index"' do
        expect(subject).not_to permit(user, customer)
      end
    end
    permissions :show? do
      it 'denies access "show"' do
        expect(subject).not_to permit(user, customer)
      end
    end
    permissions :merge? do
      it 'denies access "merge"' do
        expect(subject).not_to permit(user, customer)
      end
    end
    permissions :new? do
      it 'denies access "new"' do
        expect(subject).not_to permit(user, customer)
      end
    end
    permissions :create? do
      it 'denies access "create"' do
        expect(subject).not_to permit(user, customer)
      end
    end
    permissions :edit? do
      it 'denies access "edit"' do
        expect(subject).not_to permit(user, customer)
      end
    end
    permissions :update? do
      it 'denies access "update"' do
        expect(subject).not_to permit(user, customer)
      end
    end
    permissions :destroy? do
      it 'denies access "destroy"' do
        expect(subject).not_to permit(user, customer)
      end
    end
    permissions :work? do
      it 'denies access "work"' do
        expect(subject).not_to permit(user, customer)
      end
    end
  end

  context 'when user have role "Obserwator Klientów"' do
    let(:user) { FactoryGirl.create(:user, :as_customer_observer) }
    permissions :index? do
      it 'grants access "index"' do
        expect(subject).to permit(user, customer)
      end
    end
    permissions :show? do
      it 'grants access "show"' do
        expect(subject).to permit(user, customer)
      end
    end
    permissions :merge? do
      it 'denies access "merge"' do
        expect(subject).not_to permit(user, customer)
      end
    end
    permissions :new? do
      it 'denies access "new"' do
        expect(subject).not_to permit(user, customer)
      end
    end
    permissions :create? do
      it 'denies access "create"' do
        expect(subject).not_to permit(user, customer)
      end
    end
    permissions :edit? do
      it 'denies access "edit"' do
        expect(subject).not_to permit(user, customer)
      end
    end
    permissions :update? do
      it 'denies access "update"' do
        expect(subject).not_to permit(user, customer)
      end
    end
    permissions :destroy? do
      it 'denies access "destroy"' do
        expect(subject).not_to permit(user, customer)
      end
    end
    permissions :work? do
      it 'denies access "work"' do
        expect(subject).not_to permit(user, customer)
      end
    end

  end

  context 'when user have role "Menadżer Klientów"' do
    let(:user) { FactoryGirl.create(:user, :as_customer_manager) }
    permissions :index? do
      it 'grants access "index"' do
        expect(subject).to permit(user, customer)
      end
    end
    permissions :show? do
      it 'grants access "show"' do
        expect(subject).to permit(user, customer)
      end
    end
    permissions :merge? do
      it 'grants access "merge"' do
        expect(subject).to permit(user, customer)
      end
    end
    permissions :new? do
      it 'grants access "new"' do
        expect(subject).to permit(user, customer)
      end
    end
    permissions :create? do
      it 'grants access "create"' do
        expect(subject).to permit(user, customer)
      end
    end
    permissions :edit? do
      it 'grants access "edit"' do
        expect(subject).to permit(user, customer)
      end
    end
    permissions :update? do
      it 'grants access "update"' do
        expect(subject).to permit(user, customer)
      end
    end
    permissions :destroy? do
      it 'grants access "destroy"' do
        expect(subject).to permit(user, customer)
      end
    end
    permissions :work? do
      it 'grants access "work"' do
        expect(subject).to permit(user, customer)
      end
    end

  end



end
