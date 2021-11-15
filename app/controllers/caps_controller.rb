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
    direction = params['direction']
    num = params['num']
    if params['nam'].match(/\d+_\d+x\d+/)
      name = params[:nam].gsub(/_/,'.')
      name.sub!(/(.*)\./, '\1_')
      nam = Nam.where(nam: name).first
    else
      nam = Nam.where(nam: params[:nam].gsub(/_/,' ')).first
      puts nam.id
    end

    cap = Cap.where(
      nam_id: nam.id,
      num: num
    ).first
    puts !!cap
    if direction then
      cap = direction.match('prev') ? cap.previous : cap.next
    end
    render json: {num: cap.num, neighborNums: {num_prev: cap.previous.num, num_next: cap.next.num},  caps: cap.group(num_records)}
  end

  def neighbor_nums
    num = params['num']
    num_prev = nil
    num_next = nil
    if params['nam'].match(/\d+_\d+x\d+/)
      name = params[:nam].gsub(/_/,'.')
      name.sub!(/(.*)\./, '\1_')
      nam = Nam.where(nam: name).first
    else
      nam = Nam.where(nam: params[:nam].gsub(/_/,' ')).first
      puts nam.id
    end

    cap = Cap.where(
      nam_id: nam.id,
      num: num
    ).first

    if cap then
      num_prev = cap.previous.num
      num_next = cap.next.num
    end

    render json: {
      neighborNums: {
        num_prev: num_prev,
        num_next: num_next,
      }
    }
  end

end
