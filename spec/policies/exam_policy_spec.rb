require 'rails_helper'

describe ExamPolicy do
  let(:exam) { FactoryBot.build(:exam) }
  let(:exam_l) { FactoryBot.build(:exam, :lot) }
  let(:exam_m) { FactoryBot.build(:exam, :mor) }
  let(:exam_r) { FactoryBot.build(:exam, :ra) }
  let(:user) { FactoryBot.create(:user) }

  subject { described_class }

  context 'when user without roles' do
    permissions :index_l? do
      it 'denies access "index_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :index_m? do
      it 'denies access "index_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :index_r? do
      it 'denies access "index_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :index? do
      it 'denies access "index"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :show_l? do
      it 'denies access "show_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :show_m? do
      it 'denies access "show_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :show_r? do
      it 'denies access "show_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :show? do
      it 'denies access "show"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :new_l? do
      it 'denies access "new_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :new_m? do
      it 'denies access "new_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :new_r? do
      it 'denies access "new_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :new? do
      it 'denies access "new"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :create_l? do
      it 'denies access "create_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :create_m? do
      it 'denies access "create_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :create_r? do
      it 'denies access "create_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :create? do
      it 'denies access "create"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :edit_l? do
      it 'denies access "edit_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :edit_m? do
      it 'denies access "edit_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :edit_r? do
      it 'denies access "edit_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :edit? do
      it 'denies access "edit"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :update_l? do
      it 'denies access "update_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :update_m? do
      it 'denies access "update_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :update_r? do
      it 'denies access "update_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :update? do
      it 'denies access "update"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :destroy_l? do
      it 'denies access "destroy_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :destroy_m? do
      it 'denies access "destroy_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :destroy_r? do
      it 'denies access "destroy_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :destroy? do
      it 'denies access "destroy"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :print_l? do
      it 'denies access "print_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :print_m? do
      it 'denies access "print_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :print_r? do
      it 'denies access "print_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :print? do
      it 'denies access "print"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :work_l? do
      it 'denies access "work_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :work_m? do
      it 'denies access "work_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :work_r? do
      it 'denies access "work_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :work? do
      it 'denies access "work"' do
        expect(subject).not_to permit(user, exam)
      end
    end
  end

  context 'when user have role "Obserwator Sesji Egzaminacyjnych LOT"' do
    let(:user) { FactoryBot.create(:user, :as_exam_l_observer) }
    permissions :index_l? do
      it 'grants access "index_l" - LOT' do
        expect(subject).to permit(user, exam_l)
      end
    end
    permissions :show_l? do
      it 'grants access "show_l" - LOT' do
        expect(subject).to permit(user, exam_l)
      end
    end
    permissions :index_m? do
      it 'denies access "index_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :index_r? do
      it 'denies access "index_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :index? do
      it 'denies access "index"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :show_m? do
      it 'denies access "show_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :show_r? do
      it 'denies access "show_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :show? do
      it 'denies access "show"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :new_l? do
      it 'denies access "new_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :new_m? do
      it 'denies access "new_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :new_r? do
      it 'denies access "new_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :new? do
      it 'denies access "new"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :create_l? do
      it 'denies access "create_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :create_m? do
      it 'denies access "create_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :create_r? do
      it 'denies access "create_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :create? do
      it 'denies access "create"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :edit_l? do
      it 'denies access "edit_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :edit_m? do
      it 'denies access "edit_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :edit_r? do
      it 'denies access "edit_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :edit? do
      it 'denies access "edit"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :update_l? do
      it 'denies access "update_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :update_m? do
      it 'denies access "update_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :update_r? do
      it 'denies access "update_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :update? do
      it 'denies access "update"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :destroy_l? do
      it 'denies access "destroy_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :destroy_m? do
      it 'denies access "destroy_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :destroy_r? do
      it 'denies access "destroy_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :destroy? do
      it 'denies access "destroy"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :print_l? do
      it 'denies access "print_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :print_m? do
      it 'denies access "print_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :print_r? do
      it 'denies access "print_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :print? do
      it 'denies access "print"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :work_l? do
      it 'denies access "work_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :work_m? do
      it 'denies access "work_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :work_r? do
      it 'denies access "work_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :work? do
      it 'denies access "work"' do
        expect(subject).not_to permit(user, exam)
      end
    end
  end

  context 'when user have role "Menadżer Sesji Egzaminacyjnych LOT"' do
    let(:user) { FactoryBot.create(:user, :as_exam_l_manager) }
    permissions :index_l? do
      it 'grants access "index_l" - LOT' do
        expect(subject).to permit(user, exam_l)
      end
    end
    permissions :show_l? do
      it 'grants access "show_l" - LOT' do
        expect(subject).to permit(user, exam_l)
      end
    end
    permissions :new_l? do
      it 'grants access "new_l" - LOT' do
        expect(subject).to permit(user, exam_l)
      end
    end
    permissions :create_l? do
      it 'grants access "create_l" - LOT' do
        expect(subject).to permit(user, exam_l)
      end
    end
    permissions :edit_l? do
      it 'grants access "edit_l" - LOT' do
        expect(subject).to permit(user, exam_l)
      end
    end
    permissions :update_l? do
      it 'grants access "update_l" - LOT' do
        expect(subject).to permit(user, exam_l)
      end
    end
    permissions :destroy_l? do
      it 'grants access "destroy_l" - LOT' do
        expect(subject).to permit(user, exam_l)
      end
    end
    permissions :print_l? do
      it 'grants access "print_l" - LOT' do
        expect(subject).to permit(user, exam_l)
      end
    end
    permissions :work_l? do
      it 'grants access "work_l"' do
        expect(subject).to permit(user, exam)
      end
    end
    permissions :index_m? do
      it 'denies access "index_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :index_r? do
      it 'denies access "index_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :index? do
      it 'denies access "index"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :show_m? do
      it 'denies access "show_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :show_r? do
      it 'denies access "show_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :show? do
      it 'denies access "show"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :new_m? do
      it 'denies access "new_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :new_r? do
      it 'denies access "new_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :new? do
      it 'denies access "new"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :create_m? do
      it 'denies access "create_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :create_r? do
      it 'denies access "create_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :create? do
      it 'denies access "create"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :edit_m? do
      it 'denies access "edit_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :edit_r? do
      it 'denies access "edit_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :edit? do
      it 'denies access "edit"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :update_m? do
      it 'denies access "update_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :update_r? do
      it 'denies access "update_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :update? do
      it 'denies access "update"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :destroy_m? do
      it 'denies access "destroy_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :destroy_r? do
      it 'denies access "destroy_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :destroy? do
      it 'denies access "destroy"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :print_m? do
      it 'denies access "print_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :print_r? do
      it 'denies access "print_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :print? do
      it 'denies access "print"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :work_m? do
      it 'denies access "work_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :work_r? do
      it 'denies access "work_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :work? do
      it 'denies access "work"' do
        expect(subject).not_to permit(user, exam)
      end
    end
  end

  context 'when user have role "Obserwator Sesji Egzaminacyjnych MOR"' do
    let(:user) { FactoryBot.create(:user, :as_exam_m_observer) }
    permissions :index_m? do
      it 'grants access "index_m" - MOR' do
        expect(subject).to permit(user, exam_m)
      end
    end
    permissions :show_m? do
      it 'grants access "show_m" - MOR' do
        expect(subject).to permit(user, exam_m)
      end
    end
    permissions :index_l? do
      it 'denies access "index_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :index_r? do
      it 'denies access "index_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :index? do
      it 'denies access "index"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :show_l? do
      it 'denies access "show_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :show_r? do
      it 'denies access "show_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :show? do
      it 'denies access "show"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :new_m? do
      it 'denies access "new_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :new_l? do
      it 'denies access "new_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :new_r? do
      it 'denies access "new_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :new? do
      it 'denies access "new"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :create_m? do
      it 'denies access "create_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :create_l? do
      it 'denies access "create_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :create_r? do
      it 'denies access "create_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :create? do
      it 'denies access "create"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :edit_m? do
      it 'denies access "edit_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :edit_l? do
      it 'denies access "edit_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :edit_r? do
      it 'denies access "edit_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :edit? do
      it 'denies access "edit"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :update_m? do
      it 'denies access "update_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :update_l? do
      it 'denies access "update_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :update_r? do
      it 'denies access "update_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :update? do
      it 'denies access "update"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :destroy_m? do
      it 'denies access "destroy_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :destroy_l? do
      it 'denies access "destroy_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :destroy_r? do
      it 'denies access "destroy_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :destroy? do
      it 'denies access "destroy"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :print_m? do
      it 'denies access "print_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :print_l? do
      it 'denies access "print_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :print_r? do
      it 'denies access "print_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :print? do
      it 'denies access "print"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :work_m? do
      it 'denies access "work_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :work_l? do
      it 'denies access "work_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :work_r? do
      it 'denies access "work_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :work? do
      it 'denies access "work"' do
        expect(subject).not_to permit(user, exam)
      end
    end
  end

  context 'when user have role "Menadżer Sesji Egzaminacyjnych MOR"' do
    let(:user) { FactoryBot.create(:user, :as_exam_m_manager) }
    permissions :index_m? do
      it 'grants access "index_m" - MOR' do
        expect(subject).to permit(user, exam_m)
      end
    end
    permissions :show_m? do
      it 'grants access "show_m" - MOR' do
        expect(subject).to permit(user, exam_m)
      end
    end
    permissions :new_m? do
      it 'grants access "new_m" - MOR' do
        expect(subject).to permit(user, exam_m)
      end
    end
    permissions :create_m? do
      it 'grants access "create_m" - MOR' do
        expect(subject).to permit(user, exam_m)
      end
    end
    permissions :edit_m? do
      it 'grants access "edit_m" - MOR' do
        expect(subject).to permit(user, exam_m)
      end
    end
    permissions :update_m? do
      it 'grants access "update_m" - MOR' do
        expect(subject).to permit(user, exam_m)
      end
    end
    permissions :destroy_m? do
      it 'grants access "destroy_m" - MOR' do
        expect(subject).to permit(user, exam_m)
      end
    end
    permissions :print_m? do
      it 'grants access "print_m" - MOR' do
        expect(subject).to permit(user, exam_m)
      end
    end
    permissions :work_m? do
      it 'grants access "work_m"' do
        expect(subject).to permit(user, exam)
      end
    end
    permissions :index_l? do
      it 'denies access "index_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :index_r? do
      it 'denies access "index_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :index? do
      it 'denies access "index"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :show_l? do
      it 'denies access "show_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :show_r? do
      it 'denies access "show_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :show? do
      it 'denies access "show"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :new_l? do
      it 'denies access "new_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :new_r? do
      it 'denies access "new_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :new? do
      it 'denies access "new"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :create_l? do
      it 'denies access "create_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :create_r? do
      it 'denies access "create_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :create? do
      it 'denies access "create"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :edit_l? do
      it 'denies access "edit_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :edit_r? do
      it 'denies access "edit_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :edit? do
      it 'denies access "edit"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :update_l? do
      it 'denies access "update_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :update_r? do
      it 'denies access "update_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :update? do
      it 'denies access "update"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :destroy_l? do
      it 'denies access "destroy_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :destroy_r? do
      it 'denies access "destroy_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :destroy? do
      it 'denies access "destroy"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :print_l? do
      it 'denies access "print_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :print_r? do
      it 'denies access "print_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :print? do
      it 'denies access "print"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :work_l? do
      it 'denies access "work_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :work_r? do
      it 'denies access "work_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :work? do
      it 'denies access "work"' do
        expect(subject).not_to permit(user, exam)
      end
    end
  end

  context 'when user have role "Obserwator Sesji Egzaminacyjnych RA"' do
    let(:user) { FactoryBot.create(:user, :as_exam_r_observer) }
    permissions :index_r? do
      it 'grants access "index_r" - RA' do
        expect(subject).to permit(user, exam_r)
      end
    end
    permissions :show_r? do
      it 'grants access "show_r" - RA' do
        expect(subject).to permit(user, exam_r)
      end
    end
    permissions :index_l? do
      it 'denies access "index_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :index_m? do
      it 'denies access "index_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :index? do
      it 'denies access "index"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :show_l? do
      it 'denies access "show_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :show_m? do
      it 'denies access "show_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :show? do
      it 'denies access "show"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :new_r? do
      it 'denies access "new_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :new_l? do
      it 'denies access "new_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :new_m? do
      it 'denies access "new_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :new? do
      it 'denies access "new"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :create_r? do
      it 'denies access "create_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :create_l? do
      it 'denies access "create_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :create_m? do
      it 'denies access "create_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :create? do
      it 'denies access "create"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :edit_r? do
      it 'denies access "edit_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :edit_l? do
      it 'denies access "edit_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :edit_m? do
      it 'denies access "edit_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :edit? do
      it 'denies access "edit"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :update_r? do
      it 'denies access "update_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :update_l? do
      it 'denies access "update_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :update_m? do
      it 'denies access "update_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :update? do
      it 'denies access "update"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :destroy_r? do
      it 'denies access "destroy_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :destroy_l? do
      it 'denies access "destroy_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :destroy_m? do
      it 'denies access "destroy_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :destroy? do
      it 'denies access "destroy"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :print_r? do
      it 'denies access "print_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :print_l? do
      it 'denies access "print_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :print_m? do
      it 'denies access "print_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :print? do
      it 'denies access "print"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :work_r? do
      it 'denies access "work_r" - RA' do
        expect(subject).not_to permit(user, exam_r)
      end
    end
    permissions :work_l? do
      it 'denies access "work_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :work_m? do
      it 'denies access "work_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :work? do
      it 'denies access "work"' do
        expect(subject).not_to permit(user, exam)
      end
    end
  end

  context 'when user have role "Menadżer Sesji Egzaminacyjnych RA"' do
    let(:user) { FactoryBot.create(:user, :as_exam_r_manager) }
    permissions :index_r? do
      it 'grants access "index_r" - RA' do
        expect(subject).to permit(user, exam_r)
      end
    end
    permissions :show_r? do
      it 'grants access "show_r" - RA' do
        expect(subject).to permit(user, exam_r)
      end
    end
    permissions :new_r? do
      it 'grants access "new_r" - RA' do
        expect(subject).to permit(user, exam_r)
      end
    end
    permissions :create_r? do
      it 'grants access "create_r" - RA' do
        expect(subject).to permit(user, exam_r)
      end
    end
    permissions :edit_r? do
      it 'grants access "edit_r" - RA' do
        expect(subject).to permit(user, exam_r)
      end
    end
    permissions :update_r? do
      it 'grants access "update_r" - RA' do
        expect(subject).to permit(user, exam_r)
      end
    end
    permissions :destroy_r? do
      it 'grants access "destroy_r" - RA' do
        expect(subject).to permit(user, exam_r)
      end
    end
    permissions :print_r? do
      it 'grants access "print_r" - RA' do
        expect(subject).to permit(user, exam_r)
      end
    end
    permissions :work_r? do
      it 'grants access "work_r"' do
        expect(subject).to permit(user, exam)
      end
    end
    permissions :index_l? do
      it 'denies access "index_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :index_m? do
      it 'denies access "index_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :index? do
      it 'denies access "index"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :show_l? do
      it 'denies access "show_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :show_m? do
      it 'denies access "show_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :show? do
      it 'denies access "show"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :new_l? do
      it 'denies access "new_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :new_m? do
      it 'denies access "new_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :new? do
      it 'denies access "new"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :create_l? do
      it 'denies access "create_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :create_m? do
      it 'denies access "create_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :create? do
      it 'denies access "create"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :edit_l? do
      it 'denies access "edit_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :edit_m? do
      it 'denies access "edit_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :edit? do
      it 'denies access "edit"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :update_l? do
      it 'denies access "update_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :update_m? do
      it 'denies access "update_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :update? do
      it 'denies access "update"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :destroy_l? do
      it 'denies access "destroy_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :destroy_m? do
      it 'denies access "destroy_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :destroy? do
      it 'denies access "destroy"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :print_l? do
      it 'denies access "print_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :print_m? do
      it 'denies access "print_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :print? do
      it 'denies access "print"' do
        expect(subject).not_to permit(user, exam)
      end
    end
    permissions :work_l? do
      it 'denies access "work_l" - LOT' do
        expect(subject).not_to permit(user, exam_l)
      end
    end
    permissions :work_m? do
      it 'denies access "work_m" - MOR' do
        expect(subject).not_to permit(user, exam_m)
      end
    end
    permissions :work? do
      it 'denies access "work"' do
        expect(subject).not_to permit(user, exam)
      end
    end
  end
end
