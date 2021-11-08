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
