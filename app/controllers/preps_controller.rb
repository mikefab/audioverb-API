class PrepsController < ApplicationController

  def preps
      lng = Lng.where(lng: params[:lng]).first
      @preps = lng.preps.all
      return render json: {
        prepositions: @preps.sort().map{ |p| p.prep}.uniq
      }
    render json: {message: 'empty'}
  end

  def preps_by_nam
    if params[:nam]
      nam = Nam.find_by_nam(params[:nam])
      @preps = nam.preps.all
      return render json: {
        prepositions: @preps.sort().map{ |p| p.prep}.uniq
      }
    end
    render json: {message: 'empty'}
  end

end
