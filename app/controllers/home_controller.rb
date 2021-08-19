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

  def tenses
    englishId = Lng.where(lng: 'english').first.id

    if Rails.cache.exist?("tenses-#{params[:language]}")
      render json: Rails.cache.read("tenses-#{params[:language]}")
    else
     lng_id = Lng.where(lng: params[:language]).first.id
     puts "#{englishId} #{lng_id}"
    puts Tense.get_tenses_for_native(englishId, lng_id)
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
  def save_cut
    puts ENV.fetch("USER_CODE")
    nam = params[:name].gsub('_', ' ')
    num = params[:num]
    start = params[:start].gsub('-', '.')
    stop = params[:stop].gsub('-', '.')
    user_id = params[:user_code]
    if ENV.fetch("USER_CODE")===user_id then
      puts nam
      nam_id = Nam.find_by(nam: nam).id
      cap = Cap.find_by(nam_id: nam_id, num: num)
      cut = Cut.find_by(nam: nam, num: num, user_id: user_id)
      if !cut and cap then
        Cut.create(cap: cap, start: start, stop: stop, user_id: user_id, nam: nam, num: num, hashed_ip: request.remote_ip.hash)
      elsif cut && cap
        cut.update(start: start, stop: stop)
      end
      render json: {message: 'cut updated'}
    else
      render json: {error: 'not authorized'}
    end

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
