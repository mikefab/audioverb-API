class TensesController < ApplicationController

  def tenses
    if Rails.cache.exist?("tenses-#{params[:language]}")
      render json: Rails.cache.read("tenses-#{params[:language]}")
    else
     lng_id = Lng.where(lng: params[:language]).first.id
      # get all tenses for selected native language
      # For now just test against English
      @native_tenses = Tense.tenses(lng_id)
      render json: Rails.cache.fetch("tenses-#{params[:language]}", :expires_in => 3.days){ @native_tenses }
    end
  end
end
