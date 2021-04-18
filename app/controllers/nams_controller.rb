class NamsController < ApplicationController

  def all
    puts "HI"
    render json: Nam.all
  end
  # respond_to :json
  def search
    #flare = Nam.to_flare(params[:search])
    media  = params[:media]
    search = params[:search]
    if Rails.cache.exist?("nam-search-#{media}-#{search}")
      render json: Rails.cache.read("nam-search-#{media}-#{search}")
    else
      render json: Rails.cache.fetch("nam-search-#{media}-#{search}", :expires_in => 3.days){ Nam.to_flare(media, search)}
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
