class CapsController < ApplicationController

  def cap_by_nam_num
    if params['nam'].match(/\d+_\d+x\d+/)
      name = params[:nam].gsub(/_/,'.')
      name.sub!(/(.*)\./, '\1_')
      nam = Nam.where(nam: name).first
    else
      nam = Nam.where(nam: params[:nam].gsub(/_/,' ')).first
      puts nam.id
    end
    render json: Cap.where(
      nam_id: nam.id,
      num: params[:num]
    ).first.to_json(:include => [:subs, :nam])

  end

end
