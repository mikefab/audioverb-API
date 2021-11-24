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
end
