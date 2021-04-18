class OrdersController < ApplicationController

#used on server that stores pngs.
  def return_names
    output = %x!bash return_names.sh!
    render :text => output
  end

def combine

  # if params[:source].match(/\^/) then
  #   (source,name,start,stop,format)=params[:source].split(/\^/)
  # else
    language = params[:language]
    source  = params[:source]
    name    = params[:name]
    start   = params[:start]
    stop    = params[:stop]
    format  = params[:format]
  # end
  stop = stop.to_i if stop.to_s.match(/\.0/)
  start = start.to_i if start.to_s.match(/\.0/)
  puts "#{start} #{stop} !!!!!"
  range = stop.to_i-start.to_i
  logger.info "#{range} <-- RANGE!\n"
  if range <120 then
      i       = start.to_f
      puts "public/audio/#{language}/#{name}"
    # if(format.match(/mp3/)) then
      command=""
      if File.directory?("public/audio/#{language}/#{name}") then
        command = "cat "
        while i <= stop.to_f
          i=i.to_i if i%1==0
          command = command + "#{i}_#{name}.mp3 "
          i+=0.5
        end
        command = command + " > #{start}~#{stop}_#{name}.mp3"
      end
    # end

#     if(format.match(/png/)) then
#       command=""
#       if File.directory?("public/#{format}/#{source}/#{name}") || File.directory?("public/#{format}/tv/#{source}/#{name}") then
#         logger.debug "FILE directory?????\n"
#         command = "convert +append "
#         while i <= stop.to_f
#           i=i.to_i if i%1==0
# #        command = command + "#{i}_#{name}.png ~/mikefab/public/images/bar_black.png  "
#           command = command + "#{i}_#{name}.png  "
#           i+=0.5
#         end
#         command = command + "  #{start}~#{stop}_#{name}.png"
#       end
#     end

      # if source.match(/movies/) then
      #   system("cd public/#{format}/#{source}/#{name}; #{command}")
      #   redirect_to "/#{format}/#{source}/#{name}/#{start}~#{stop}_#{name}.#{format}"
      # elsif source.match(/^dotsub/) then
      #   system("cd public/#{format}/#{source}/#{name}; #{command}")
      #   redirect_to "/#{format}/#{source}/#{name}/#{start}~#{stop}_#{name}.#{format}"
      # else
      #    system("cd public/#{format}/tv/#{source}/#{name}; #{command}")
      #    logger.fatal "#{command} <---- command \n"
      #    redirect_to "/#{format}/tv/#{source}/#{name}/#{start}~#{stop}_#{name}.#{format}"
      # end
      puts "#{command} CCCC"
      render json: []
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
