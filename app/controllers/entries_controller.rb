class EntriesController < ApplicationController

  def idioms
    if params[:language].match(/chinese/)
      lng = Lng.where(cod: 'chi_hans').first
      @idioms = lng.entries.all
      return render json: {
        idioms: @idioms.sort_by{|e| e[:kanji_id]}.map{ |idiom| idiom.entry}
      }
    end
    render json: {message: 'empty'}
  end

  def idioms_by_media
    if params[:media]
      nam = Nam.where(nam: params[:media]).first
      @idioms = nam.entries.all
      return render json: {
        idioms: @idioms.sort_by{|e| e[:kanji_id]}.map{ |idiom| idiom.entry}
      }
    end
    render json: {message: 'empty'}
  end

end
