class NamsController < ApplicationController

  def all
    render json: Nam.all
  end
  # respond_to :json
  def search_by_nam
    #flare = Nam.to_flare(params[:search])
    media  = params[:media]
    search = params[:search]

    if Rails.cache.exist?("nam-search-#{media}-#{search}")
      render json: Rails.cache.read("nam-search-#{media}-#{search}")
    else
      render json: Rails.cache.fetch("nam-search-#{media}-#{search}", :expires_in => 3.days){ Nam.to_flare_single(media, search)}
    end
    #render json: flare #Nam.search("\"#{params[:search]}\"").to_json(:search => params[:search])
  end

  def verbs_for_nam
    nam  = params[:nam]
    if Rails.cache.exist?("verbs_for_nam-#{nam}")
      render json: Rails.cache.read("verbs_for_nam-#{nam}")
    else
      h = {}
      Nam.find_by_nam(nam).caps.each do |cap|
        #cap.clas { |cla| puts cla.verb_id}
        cap.clas.each do |cla|
          verb = Verb.find(cla.verb_id)
           #h[verb.verb] = h[verb.verb] ? h[verb.verb] + 1 : 1

          if !!h[verb.verb] then
            if !h[verb.verb].include? cla.cla then
              h[verb.verb].push(cla.cla)
            end
          else
             h[verb.verb] = [cla.cla]
          end
        end
      end
      render json: Rails.cache.fetch("verbs_for_nam-#{nam}", :expires_in => 3.days) {h}
    end
  end


  def conjugations_for_nam
    nam  = params[:nam]
    verb_name = params[:verb]
    if Rails.cache.exist?("conjugations_for_nam-#{nam}-#{verb_name}")
      render json: Rails.cache.read("conjugations_for_nam-#{nam}-#{verb_name}")
    else
      verb = Verb.find_by_verb(verb_name)
      if !verb then
        return render json: []
      end
      h = {}
      Nam.find_by_nam(nam).caps.each do |cap|
        #cap.clas { |cla| puts cla.verb_id}
        cap.clas.each do |cla|
          if verb.id === cla.verb_id
            tense = Tense.find(cla.tense_id).tense


            if !!h[tense] then
              if !h[tense].include? cla.cla then
                h[tense].push(cla.cla)
              end
            else
               h[tense] = [cla.cla]
            end
          end
        end
      end
      render json: Rails.cache.fetch("conjugations_for_nam-#{nam}-#{verb_name}", :expires_in => 3.days) {h}
    end
  end

  def caps_by_nam
    media  = params[:nam]
    nam = Nam.find_by_nam(media)
    render json: nam.caps.all.map{ |c| {
        cap: c.cap,
        num: c.num,
        start: c.start,
        stop: c.stop,
        wcount: c.wcount,
        last_cap_stop: c.last_cap_stop
      }
    }


  end
  def search
    search = params[:search]
    lng_id = Lng.where(cod: params[:lng]).first.id
    puts "#{lng_id} #{search} ssss"
    if Rails.cache.exist?("search-#{lng_id}-#{search}")
      render json: Rails.cache.read("search-#{lng_id}-#{search}")
    else
      render json: Rails.cache.fetch("search-#{lng_id}h-#{search}", :expires_in => 3.days){ Nam.to_flare(search, lng_id)}
    end
    #render json: flare #Nam.search("\"#{params[:search]}\"").to_json(:search => params[:search])
  end

  def search_caps_nam
    if Rails.cache.exist?("nam-cap-search-" + params[:nam] + "-" + params[:search])

      render json: Rails.cache.read("nam-cap-search-" + params[:nam] + "-" + params[:search])
    else
      nam = Nam.decode(params[:nam])

      n = Nam.where(nam: nam).first
      puts params[:search]
      caps = n.get_caps_by_search(params[:search])
      caps = caps.to_json
      #render json: caps

      render json: Rails.cache.fetch("nam-cap-search-" + params[:nam] + "-" + params[:search], :expires_in => 3.days){ caps }
    end
  end

  def list
    if Rails.cache.exist?("list-#{params[:language]}")
      render json: Rails.cache.read("list-#{params[:language]}")
    else
      lng_id = Lng.where(lng: params[:language]).first.id
      render json: Rails.cache.fetch("list-#{params[:language]}", :expires_in => 3.days){ Nam.where(lng_id: lng_id).order(:created_at).reverse}
    end
  end
end
