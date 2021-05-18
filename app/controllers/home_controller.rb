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

  def conjugation
    tense_id = Tense.where(tense: params[:tense]).first.id
    verb_id = Verb.where(verb: params[:verb]).first.id
    conjugations = Cla.where(tense_id: tense_id, verb_id: verb_id)
    if Rails.cache.exist?("conjugation-#{params[:conjugation]}")
      render json: Rails.cache.read("conjugation-#{params[:conjugation]}")
    else
      #verbs = Tense.return_tense_verbs(Tense.where(tense: "#{params[:tense]}").first.id, englishId)
      render json: Rails.cache.fetch("conjugation-#{params[:conjugation]}", :expires_in => 3.days) {
        conjugations.map{ |e|  e[:cla]}

      }
    end
  end
end
