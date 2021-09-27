class CutsController < ApplicationController

  def cuts_by_nam
    if params[:nam]
      cuts = Cut.where(nam: params[:nam])
      return render json: {
        cuts: cuts.map{ |cut| {num: cut.num, start: cut.start, stop: cut.stop} }
      }
    end
    render json: {message: 'empty'}
  end


  def save_cut
    puts ENV.fetch("USER_CODE")
    nam = params[:name].gsub('_', ' ')
    num = params[:num]
    start = params[:start].gsub('-', '.')
    stop = params[:stop].gsub('-', '.')
    user_id = params[:user_code]
    if ENV.fetch("USER_CODE")===user_id then
      puts nam
      nam_id = Nam.find_by(nam: nam).id
      cap = Cap.find_by(nam_id: nam_id, num: num)
      cut = Cut.find_by(nam: nam, num: num, user_id: user_id)
      if !cut and cap then
        # Cap is being cut for first time. Let anyone do it.
        Cut.create(cap: cap, start: start, stop: stop, user_id: user_id, nam: nam, num: num, hashed_ip: request.remote_ip.hash)
      elsif cut && cap
        # Cap exists. If cut by admin, only update if this cut is submitted by admin
        if cut.user_id === ENV.fetch("USER_CODE") and user_id ===  ENV.fetch("USER_CODE") then
          cut.update(start: start, stop: stop)
        end
        # Cut is being overwritten by admin's submission
        if cut.user_id != ENV.fetch("USER_CODE") and user_id ===  ENV.fetch("USER_CODE") then
          cut.update(start: start, stop: stop)
        else
          render json: {error: 'This cut cannot be overwritten.'}
        end
      end
      render json: {message: 'cut updated'}
    else
      render json: {error: 'not authorized'}
    end

    #if Rails.cache.exist?("conjugation-#{params[:conjugation]}")
    #  render json: Rails.cache.read("conjugation-#{params[:conjugation]}")
    #else
    #  #verbs = Tense.return_tense_verbs(Tense.where(tense: "#{params[:tense]}").first.id, englishId)
    #  render json: Rails.cache.fetch("conjugation-#{params[:conjugation]}", :expires_in => 3.days) {
    #    conjugations.map{ |e|  e[:cla]}

    #  }
    #end
  end
end
