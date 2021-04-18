class HomeController < ApplicationController
  def home
  end
  def tense #User has clicked on a tense in the noframes tense page
    englishId = Lng.where(lng: 'english').first.id
    if Rails.cache.exist?("tense-#{params[:tense]}")
      render json: Rails.cache.read("tense-#{params[:tense]}")
    else
      verbs = Tense.return_tense_verbs(Tense.where(tense: "#{params[:tense]}").first.id, englishId)
      render json: Rails.cache.fetch("tense-#{params[:tense]}", :expires_in => 3.days){ verbs }
    end
  end

  def tenses
    englishId = Lng.where(lng: 'english').first.id
    if Rails.cache.exist?("tenses-#{params[:language]}")
      render json: Rails.cache.read("tenses-#{params[:language]}")
    else
     lng_id = Lng.where(lng: params[:language]).first.id
      # get all tenses for selected native language
      # For now just test against English
      @native_tenses = Tense.get_tenses_for_native(englishId, lng_id)
      render json: Rails.cache.fetch("tenses-#{params[:language]}", :expires_in => 3.days){ @native_tenses.keys }
    end
  end
end
