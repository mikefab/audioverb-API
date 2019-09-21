#RAILS_ENV=development rake import_movies file=house.of.flying.daggers language=chi_hans --trace
#RAILS_ENV=development rake import_movies file=love.is.not.blind language=chi_hans --trace
# RAILS_ENV=development rake import_movies file=my.life.as.mcdull language=chi_hans --trace
# RAILS_ENV=development rake import_movies file=the.tibetan.dog language=chi_hans --trace
task :import_movies => [:environment] do
  main_language_id = Lng.where(%Q/cod="#{ENV['language']}"/).first.id
  title            = ENV['file'].gsub(/\./," ") #get series for storing tag
  src              = Src.where("src='movies'").first
  unless src
    src = Src.create(:src=>"movies", :lng_id=>main_language_id)
    #src.cat_list = "movie"
    src.save!
  end
  src = Src.where("src='movies'").first
  nam = Nam.where(%Q/nam="#{title}"/).first

  unless nam
    nam = Nam.create(:nam=>"#{title}", :lng_id=>main_language_id,:src_id=>src.id)
    nam.title = "#{title}"
    nam.save!
  end

  nam = Nam.where(%Q/nam="#{title}"/).first

  basedir = "../files/movie_caps/#{ENV['language']}"
  basedir = "lib/text_files/captions/movies/#{ENV['language']}"
  file = File.new(basedir +"/#{ENV['file']}.txt", "r:iso-8859-1") unless ENV['language'].match(/chi_hans/)
  file = File.new(basedir +"/#{ENV['file']}.txt") if ENV['language'].match(/chi_hans/)
  have_source=false
  have_name=false
  ActiveRecord::Migration.suppress_messages do
    while (line = file.gets)
#      ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
#      line = ic.iconv(line + ' ')[0..-2]

      line= line.gsub(/\n/,"")
      puts line
      (source,name,c_language,language,num,start,stop,o)=line.split(/\t/)
      c_language_id= Lng.where(%Q/cod="#{c_language}"/).first.id
      language_id= Lng.where(%Q/cod="#{language}"/).first.id
      wcount=o.split(/\s+/).size.to_s
      ccount= o.size.to_s
      o=o[0,255]

      if language_id !=c_language_id
         s= Sub.new(:sub=>o,:nam_id=>nam.id,:src_id=>src.id, :lng_id=>language_id,:start=>"#{start}",:stop=>"#{stop}",:clng_id=>c_language_id,:num=>num).save
      else
         s= Cap.new(:cap=>o,:nam_id=>nam.id,:src_id=>src.id, :lng_id=>language_id,:start=>"#{start}",:stop=>"#{stop}",:num=>num,:wcount=>wcount,:ccount=>ccount).save
      end
    end
  end
end
