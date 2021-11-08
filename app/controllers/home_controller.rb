class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token
  def home
  end

  # Not sure if this is still used
  def grams
    puts params
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
    englishId = Lng.where(lng: 'english').first.id
    if Rails.cache.exist?("tense-#{params[:tense]}")
      render json: Rails.cache.read("tense-#{params[:tense]}")
    else
      verbs = Tense.return_tense_verbs(Tense.where(tense: "#{params[:tense]}").first.id, englishId)
      render json: Rails.cache.fetch("tense-#{params[:tense]}", :expires_in => 3.days){ verbs }
    end
  end


  def conjugation
    tense_id = Tense.where(tense: params[:tense]).first.id
    verb_id = Verb.where(verb: params[:verb]).first.id
    conjugations = Cla.where(tense_id: tense_id, verb_id: verb_id)
    puts "cccc ... #{conjugations}"
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
