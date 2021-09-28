class EntriesController < ApplicationController

  def yu
      kind = params[:kind]
      lng = Lng.where(cod: 'chi_hans').first

      @yu = lng.entries.where(is_idiom: !!kind.match(/chengyu/))
      return render json: {
        yu: @yu.sort_by{|e| e[:kanji_id]}.map{ |yu| yu.entry}.uniq
      }
    render json: {message: 'empty'}
  end

  def yu_by_media
    kind = params[:kind]
    if params[:media]
      nam = Nam.where(nam: params[:media]).first
      @idioms = nam.entries.where(is_idiom: !!kind.match(/chengyu/))
      return render json: {
        yu: @idioms.sort_by{|e| e[:kanji_id]}.map{ |idiom| idiom.entry}
      }
    end
    render json: {message: 'empty'}
  end

end
