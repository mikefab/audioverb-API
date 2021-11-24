class VerbsController < ApplicationController

  def verbs
    if Rails.cache.exist?("verbs-#{params[:lng]}")
      render json: Rails.cache.read("verbs-#{params[:lng]}")
    else
      # get all tenses for selected native language
      # For now just test against English
      @native_verbs = {}
      l =   Lng.where(lng: params[:lng]).first
      Lng.where(lng: params[:lng]).first.verbs.each do | v |
        @native_verbs[v.verb] = [v.clas.first.cla]
      end
      render json: Rails.cache.fetch("verbs-#{params[:lng]}", :expires_in => 3.days){ @native_verbs }
    end
  end

  def conjugation
    lng = params[:language]
    tense = params[:tense]
    verb = params[:verb]

    if Rails.cache.exist?("conjugation-#{lng}-#{tense}-#{verb}}")
     render json: Rails.cache.read("conjugation-#{lng}-#{tense}-#{verb}}")
    else
      lng_id = Lng.where(lng: lng).first.id
      tense_id = Tense.where(tense: tense, lng_id: lng_id).first.id
      verb_id = Verb.where(verb: verb, lng_id: lng_id).first.id
      conjugations = Cla.where(tense_id: tense_id, verb_id: verb_id)
      #verbs = Tense.return_tense_verbs(Tense.where(tense: "#{params[:tense]}").first.id, englishId)
      render json: Rails.cache.fetch("conjugation-#{lng}-#{tense}-#{verb}}", :expires_in => 3.days) {
        conjugations.map{ |e|  e[:cla]}
      }
    end
  end

  def conjugations
    lng_id = Lng.where(lng: params[:language]).first.id
    puts "#{lng_id} ...ddd"
    if Rails.cache.exist?("conjugations-#{lng_id}-#{params[:verb]}")
      render json: Rails.cache.read("conjugations-#{lng_id}-#{params[:verb]}")
    else
      # get all tenses for selected native language
      # For now just test against English

      @conjugations = Verb.where(lng_id: lng_id, verb: params[:verb]).first.clas.map do | c |
        c.cla
      end
      render json: Rails.cache.fetch("conjugations-#{lng_id}-#{params[:verb]}", :expires_in => 3.days){ @conjugations.uniq }
    end
  end


end
