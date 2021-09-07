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

end
