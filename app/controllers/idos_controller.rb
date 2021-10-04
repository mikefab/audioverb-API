class IdosController < ApplicationController

  def idos
      lng = Lng.where(lng: params[:lng]).first
      @idos = lng.idos.all
      return render json: {
        idioms: @idos.sort().map{ |i| i.ido}.uniq
      }
    render json: {message: 'empty'}
  end

  def idos_by_nam
    if params[:nam]
      nam = Nam.find_by_nam(params[:nam])
      @idos = nam.idos.all
      return render json: {
        idioms: @idos.sort().map{ |i| i.ido}.uniq
      }
    end
    render json: {message: 'empty'}
  end

end
