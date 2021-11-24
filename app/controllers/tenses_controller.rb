class TensesController < ApplicationController

  def tense #User has clicked on a tense in the noframes tense page
    tense = params[:tense]
    language = params[:language]
    lng_id = Lng.where(lng: language).first.id
    mood = Mood.where(mood: params[:mood], lng_id: lng_id).first


    if Rails.cache.exist?("tense-#{mood.mood}-#{tense}")
      render json: Rails.cache.read("tense-#{mood.mood}-#{tense}")
    else
      verbs = Tense.tense_verbs(Tense.where(tense: tense, mood_id: mood.id ).first.id)
      render json: Rails.cache.fetch("tense-#{mood.mood}-#{tense}", :expires_in => 3.days){ verbs }
    end
  end

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
