require 'rails_helper'

describe RolePolicy do
  let(:role) { FactoryGirl.build(:role) }
  let(:user) { FactoryGirl.create(:user) }

  subject { described_class }

  context 'when user without roles' do
    permissions :index? do
      it 'denies access "index"' do
        expect(subject).not_to permit(user, role)
      end
    end
    permissions :show? do
      it 'denies access "show"' do
        expect(subject).not_to permit(user, role)
      end
    end
    permissions :new? do
      it 'denies access "new"' do
        expect(subject).not_to permit(user, role)
      end
    end
    permissions :create? do
      it 'denies access "create"' do
        expect(subject).not_to permit(user, role)
      end
    end
    permissions :edit? do
      it 'denies access "edit"' do
        expect(subject).not_to permit(user, role)
      end
    end
    permissions :update? do
      it 'denies access "update"' do
        expect(subject).not_to permit(user, role)
      end
    end
    permissions :destroy? do
      it 'denies access "destroy"' do
        expect(subject).not_to permit(user, role)
      end
    end
    permissions :add_remove_user? do
      it 'denies access "add_remove_user"' do
        expect(subject).not_to permit(user, role)
      end
    end
    permissions :work? do
      it 'denies access "work"' do
        expect(subject).not_to permit(user, role)
      end
    end
  end

  context 'when user have role "Obserwator Ról"' do
    let(:user) { FactoryGirl.create(:user, :as_role_observer) }
    permissions :index? do
      it 'grants access "index"' do
        expect(subject).to permit(user, role)
      end
    end
    permissions :show? do
      it 'grants access "show"' do
        expect(subject).to permit(user, role)
      end
    end
    permissions :new? do
      it 'denies access "new"' do
        expect(subject).not_to permit(user, role)
      end
    end
    permissions :create? do
      it 'denies access "create"' do
        expect(subject).not_to permit(user, role)
      end
    end
    permissions :edit? do
      it 'denies access "edit"' do
        expect(subject).not_to permit(user, role)
      end
    end
    permissions :update? do
      it 'denies access "update"' do
        expect(subject).not_to permit(user, role)
      end
    end
    permissions :destroy? do
      it 'denies access "destroy"' do
        expect(subject).not_to permit(user, role)
      end
    end
    permissions :add_remove_role_user? do
      it 'denies access "add_remove_role_user"' do
        expect(subject).not_to permit(user, role)
      end
    end
    permissions :work? do
      it 'denies access "work"' do
        expect(subject).not_to permit(user, role)
      end
    end
  end

  context 'when user have role "Menadżer Ról"' do
    let(:user) { FactoryGirl.create(:user, :as_role_manager) }
    permissions :index? do
      it 'grants access "index"' do
        expect(subject).to permit(user, role)
      end
    end
    permissions :show? do
      it 'grants access "show"' do
        expect(subject).to permit(user, role)
      end
    end
    permissions :new? do
      it 'grants access "new"' do
        expect(subject).to permit(user, role)
      end
    end
    permissions :create? do
      it 'grants access "create"' do
        expect(subject).to permit(user, role)
      end
    end
    permissions :edit? do
      it 'grants access "edit"' do
        expect(subject).to permit(user, role)
      end
    end
    permissions :update? do
      it 'grants access "update"' do
        expect(subject).to permit(user, role)
      end
    end
    permissions :destroy? do
      it 'grants access "destroy"' do
        expect(subject).to permit(user, role)
      end
    end
    permissions :add_remove_role_user? do
      it 'grants access "add_remove_role_user"' do
        expect(subject).to permit(user, role)
      end
    end
    permissions :work? do
      it 'grants access "work"' do
        expect(subject).to permit(user, role)
      end
    end
  end
end
