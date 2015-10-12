class UsersController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index, :datatables_index]

  before_action :set_user, only: [:show, :edit, :update, :destroy, :account_off, :account_on, :user_permissions_to_pdf, :user_activity_to_pdf]


#  def index
#    @users = User.order(:name).all
#    authorize :user, :index?
#  end

  def index
    authorize :user, :index?
    respond_to do |format|
      format.html
    end   
  end

  # POST /companies
  def datatables_index
    respond_to do |format|
      format.json{ render json: UserDatatable.new(view_context) }
    end
  end

  def user_permissions_to_pdf
    authorize :user, :work?

    #@works = Work.where(trackable_type: 'User', trackable_id: params[:id]).order(:created_at).all
    @works = Work.where(trackable: @user, action: [:add_role, :remove_role]).order(:created_at).all

    t1 = "Konto użytkownika: #{@user.name}, #{@user.email}, (ID: #{@user.id})"
    t2 = "utworzone: #{@user.created_at.strftime("%Y-%m-%d %H:%M:%S")}"
    t3 = @user.last_activity_at.present? ? "ostatnia aktywność: #{@user.last_activity_at.strftime("%Y-%m-%d %H:%M:%S")}" : ''
    t4 = @user.deleted_at.present? ? "data wyłączenia: #{@user.deleted_at.strftime("%Y-%m-%d %H:%M:%S")}" : ''

    respond_to do |format|
      format.pdf do
        pdf = PdfUserAccountHistory.new(@works, "Historia nadawania i cofania uprawnień", t1, t2, t3, t4, view_context)
        send_data pdf.render,
        filename: "User_permissions_#{@user.name}.pdf",
        type: "application/pdf",
        disposition: "inline"   
      end
    end
    @user.works.create!(trackable_url: "#{user_path(@user)}", action: :to_pdf, user: current_user, 
                      parameters: {pdf_type: 'user_permissions', filename: "User_permissions_#{@user.name}.pdf"}.to_json)

  end

  def user_activity_to_pdf
    authorize :user, :work?

    @works = Work.where(trackable: @user, user: @user).where.not(action: [:add_role, :remove_role]).order(:created_at).all

    t1 = "Konto użytkownika: #{@user.name}, #{@user.email}, (ID: #{@user.id})"
    t2 = "utworzone: #{@user.created_at.strftime("%Y-%m-%d %H:%M:%S")}"
    t3 = @user.last_activity_at.present? ? "ostatnia aktywność: #{@user.last_activity_at.strftime("%Y-%m-%d %H:%M:%S")}" : ''
    t4 = @user.deleted_at.present? ? "data wyłączenia: #{@user.deleted_at.strftime("%Y-%m-%d %H:%M:%S")}" : ''

    respond_to do |format|
      format.pdf do
        pdf = PdfUserAccountHistory.new(@works, "Historia aktywności", t1, t2, t3, t4, view_context)
        send_data pdf.render,
        filename: "User_activity_#{@user.name}.pdf",
        type: "application/pdf",
        disposition: "inline"   
      end
    end
    @user.works.create!(trackable_url: "#{user_path(@user)}", action: :to_pdf, user: current_user, 
                      parameters: {pdf_type: 'user_activity', filename: "User_activity_#{@user.name}.pdf"}.to_json)

  end

  def show
    authorize @user, :show?
    # przepych
    # Work.create!(trackable: @user, trackable_url: "#{user_path(@user)}", action: :show, user: current_user, parameters: {})
  end

  # GET /departments/1/edit
  def edit
    authorize @user, :edit?
    #authorize :department, :edit?
  end

  def update
    authorize @user, :update?
    
    respond_to do |format|
      if @user.update_attributes(secure_params)
        Work.create!(trackable: @user, trackable_url: "#{user_path(@user)}", action: :update, user: current_user, 
          parameters: @user.previous_changes.to_json)

        format.html { redirect_to @user, notice: t('activerecord.messages.successfull.updated', data: @user.name) }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @user, :destroy?
    
    u = @user
    cu = current_user
    if @user.destroy
      Work.create!(trackable_id: u.id, trackable_type: 'User', action: :destroy, user: cu, 
        parameters: {id: u.id, name: u.name, email: u.email}.to_json)

      redirect_to users_url, notice: t('activerecord.messages.successfull.destroyed', data: u.fullname_and_id)
    else 
      flash[:alert] = t('activerecord.messages.error.destroyed', data: u.fullname_and_id)
      render :show
    end      
  end

  def account_off
    authorize @user, :update?

    @user.soft_delete
    if @user.save
      Work.create!(trackable: @user, trackable_url: "#{user_path(@user)}", action: :account_off, user: current_user, 
        parameters: {remote_ip: request.remote_ip, fullpath: request.fullpath, id: @user.id, name: @user.name, email: @user.email}.to_json)

      redirect_to @user, notice: t('activerecord.messages.successfull.account_off', data: @user.fullname_and_id)
    else 
      flash.now[:error] = t('activerecord.messages.error.account_off', data: @user.fullname_and_id)
      render :show 
    end         
  end

  def account_on
    authorize @user, :update?

    @user.deleted_at = nil
    if @user.save
      Work.create!(trackable: @user, trackable_url: "#{user_path(@user)}", action: :account_on, user: current_user, 
        parameters: {remote_ip: request.remote_ip, fullpath: request.fullpath, id: @user.id, name: @user.name, email: @user.email}.to_json)

      redirect_to @user, notice: t('activerecord.messages.successfull.account_on', data: @user.fullname_and_id)
    else 
      flash.now[:error] = t('activerecord.messages.error.account_on', data: @user.fullname_and_id)
      render :show 
    end         
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def secure_params
      params.require(:user).permit(:name, :department_id)
    end

end
