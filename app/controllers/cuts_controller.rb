class CutsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def cuts_by_nam
    if params[:nam]
      cuts = Cut.where(nam: params[:nam])
      return render json: {
        cuts: cuts.map{ |cut| {num: cut.num, start: cut.start, stop: cut.stop, approved: cut.approved} }
      }
    end
    render json: {message: 'empty'}
  end


  def approved_user(user_code)
    return user_code ===  ENV.fetch("USER_CODE") ? true : false
  end

  def save_cut

    nam = params[:name].gsub('_', ' ')
    num = params[:num]
    start = params[:start].gsub('-', '.')
    stop = params[:stop].gsub('-', '.')
    user_id = params[:user_code]
    nam_id = Nam.find_by(nam: nam).id
    cap = Cap.find_by(nam_id: nam_id, num: num)
    cut = Cut.find_by(nam: nam, num: num)
    approvable = (user_id === ENV.fetch("USER_CODE")) ? true : false

    if cap and !cut then
      # Cap is being cut for first time. Let anyone do it.
      Cut.create(cap_id: cap.id.to_i, start: start, stop: stop, user_id: user_id || 0, nam: nam, num: num.to_i, hashed_ip: request.remote_ip.hash, approved: approvable)
      return  render json: {message: 'cut updated'}
    end
    if cap && cut

      # Cap exists. If cut by admin, only update if this cut is submitted by admin
      if approved_user(user_id) then
        cut.update(start: start, stop: stop, approved: approvable)
        return  render json: {message: 'cut updated'}
      end
      # Person is not admin, they cannot overwrite an approved cut
      return render json: {error: 'This cut cannot be overwritten.'} if cut.approved
      cut.update(start: start, stop: stop, approved: approvable, hashed_ip: request.remote_ip.hash)
      return  render json: {message: 'cut updated'}
    end
      return  render json: {message: 'Cannot create cut'}
  end
end
