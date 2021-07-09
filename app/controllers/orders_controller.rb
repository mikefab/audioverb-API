class OrdersController < ApplicationController

#used on server that stores pngs.
  def return_names
    output = %x!bash return_names.sh!
    render :text => output
  end

  def combine
    if params[:source].match(/\^/) then
      (source,name,start,stop,format)=params[:source].split(/\^/)
    else
      source  = params[:source]
      name    = params[:name]
      num    = params[:num]
      start   = params[:start].gsub('_', '.')
      stop    = params[:stop].gsub('_', '.')
      format  = params[:format]
    end
    stop = stop.to_i if stop.to_s.match(/\.0/)
    start = start.to_i if start.to_s.match(/\.0/)

    dir_format = "public/#{format}/#{source}/#{name}"
    range = stop.to_i-start.to_i
    logger.info "#{range} <-- RANGE!\n"
    if range <120 then
      i = start.to_f
      if(format.match(/mp3/)) then
        command=""
        if File.directory?(dir_format) then
          command = "cat "
          while i <= stop.to_f
            i=i.to_i if i%1==0
            command = command + "#{i}_#{name}.mp3 "
            i+=0.5
          end
          command = command + " > #{start}~#{stop}_#{name}.mp3"
        end
      end
      system("cd public/#{format}/#{source}/#{name}; #{command}")
      redirect_to "/#{format}/#{source}/#{name}/#{start}~#{stop}_#{name}.#{format}?num=#{num}"
    else
  	  logger.info "range too big."
    end #end if range
  end
  def clean
    Dir.foreach('/path/to/dir') do |item|
      next if item == '.' or item == '..'
     # do work on real items
    end
  end

end
