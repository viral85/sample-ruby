class Api::V1::MembershipsController < Api::V1::BaseController

  authorize_resource :only => [:index, :eligible_members]

  expose(:membership, config: :strong, attributes: :membership_params)
  expose(:memberships)

  expose_query MembershipsQuery

  def create
    member_attributes = member_attributes_params[:member_attributes]
    membership.member ||= User.find_by(email: member_attributes[:email].downcase) || User.create!(member_attributes) if member_attributes
    membership.save!
    respond_with membership
  end

  def update
    membership.save
    respond_with membership
  end

  def destroy
    membership.destroy
    render nothing: true, status: :ok
  end

  def approve
    membership.update_attributes(:approved => true, :approved_by_user_id => current_user.id, :approved_at => DateTime.now)
    UserMailer.approved_user(membership.member, membership.organization).deliver
    render nothing: true, status: :ok
  end

  def reject
    membership.update_attributes(:approved => false, :approved_by_user_id => current_user.id, :approved_at => DateTime.now)
    render nothing: true, status: :ok
  end

  def eligible_members
    search_parameter_array = params[:term].downcase.split(' ').map { |word| "%#{word}%" }.uniq
    @members = EligibleMembersPresenter.new(params[:organization_type],
                                            search_parameter_array, params[:organization_id]).get_members
  end

  private

  def membership_params
    unless ['approve', 'reject'].include?(action_name)
      params.require(:membership).permit(:id, :organization_id, :organization_type, :member_id, :member_type,
        :role, :started_at, :ended_at, taggings_attributes: [:id, :tag_id, :_destroy])
    end
  end

  def member_attributes_params
    params.require(:membership).permit(member_attributes: [:first_name, :last_name, :email])
  end

end
