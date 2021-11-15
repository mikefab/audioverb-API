class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token
  def home
  end

  # Not sure if this is still used
  def grams
    gram_type = params[:gram].match(/monogram/) ? 1 : 2
    render json: Voc.grams(gram_type, 'all')
  end

  def level
    if Rails.cache.exist?("#{params[:gram]}-#{params[:level]}-#{params[:media]}")
      render json: Rails.cache.read("#{params[:gram]}-#{params[:level]}-#{params[:media]}")
    else
      render json: Rails.cache.fetch("#{params[:gram]}-#{params[:level]}-#{params[:media]}", :expires_in => 3.days){ Voc.level(params[:gram], params[:level], params[:media])}
    end
  end

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


  def conjugation
    tense_id = Tense.where(tense: params[:tense]).first.id
    verb_id = Verb.where(verb: params[:verb]).first.id
    conjugations = Cla.where(tense_id: tense_id, verb_id: verb_id)
    render json: conjugations.map{ |e|  e[:cla]}

    #if Rails.cache.exist?("conjugation-#{params[:conjugation]}")
    #  render json: Rails.cache.read("conjugation-#{params[:conjugation]}")
    #else
    #  #verbs = Tense.return_tense_verbs(Tense.where(tense: "#{params[:tense]}").first.id, englishId)
    #  render json: Rails.cache.fetch("conjugation-#{params[:conjugation]}", :expires_in => 3.days) {
    #    conjugations.map{ |e|  e[:cla]}

    #  }
    #end
  end
end
