class CapsController < ApplicationController

  def cap_by_nam_num
    print "#{request.query_parameters} dddd"
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

  def cap_by_nam_num_group
    num_records = params[:num_records] ? Integer(params[:num_records]) : false
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
    ).first.group(num_records).to_json(:include => [:subs, :nam])
  end

end
