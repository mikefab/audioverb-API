class VerbsController < ApplicationController

  def verbs
    if Rails.cache.exist?("verbs-#{params[:lng]}")
      render json: Rails.cache.read("verbs-#{params[:lng]}")
    else
      # get all tenses for selected native language
      # For now just test against English
      @native_verbs = {}
      Lng.where(lng: params[:lng]).first.verbs.each do | v |
        @native_verbs[v.verb] = [v.clas.first.cla]
      end
      render json: Rails.cache.fetch("verbs-#{params[:lng]}", :expires_in => 3.days){ @native_verbs }
    end
  end

  def conjugations
    if Rails.cache.exist?("conjugations-#{params[:verb]}")
      render json: Rails.cache.read("conjugations-#{params[:verb]}")
    else
      # get all tenses for selected native language
      # For now just test against English

      @conjugations = Verb.where(verb: params[:verb]).first.clas.map do | c |
        c.cla
      end
      render json: Rails.cache.fetch("conjugations-#{params[:verb]}", :expires_in => 3.days){ @conjugations.uniq }
    end
  end


end
