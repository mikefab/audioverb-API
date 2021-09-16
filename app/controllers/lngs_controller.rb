class LngsController < ApplicationController

  def languages
    if Rails.cache.exist?("lngs")
      render json: Rails.cache.read("lngs")
    else
      # get all tenses for selected native language
      # For now just test against English
      @native_verbs = {}

      render json: Rails.cache.fetch("lngs", :expires_in => 3.seconds){ Lng.available_languages() }
    end
  end
end
