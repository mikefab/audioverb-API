#RAILS_ENV=development rake import_movies file=house.of.flying.daggers language=chi_hans --trace
#RAILS_ENV=development rake import_movies file=love.is.not.blind language=chi_hans --trace
# RAILS_ENV=development rake import_movies file=my.life.as.mcdull language=chi_hans --trace
# RAILS_ENV=development rake import_movies file=the.tibetan.dog language=chi_hans --trace
# RAILS_ENV=development rake import_movies file=el.clan language=spa --trace
# RAILS_ENV=development rake import_movies file=relatos.salvajes language=spa --trace
# RAILS_ENV=development rake import_movies file=nueve.reinas language=spa --trace
# RAILS_ENV=development rake import_movies file=maria.llena.de.gracia language=spa --trace
# RAILS_ENV=development rake import_movies file=museo language=spa --trace
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
#  file = File.new(basedir +"/#{ENV['file']}.txt", "r:iso-8859-1") unless ENV['language'].match(/chi_hans/)
  file = File.new(basedir +"/#{ENV['file']}.txt", "r:utf-8") unless ENV['language'].match(/chi_hans/)
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
      puts language + "!!!!!"
      language_id= Lng.where(%Q/cod="#{language}"/).first.id
      wcount=o.split(/\s+/).size.to_s
      ccount= o.size.to_s
      o=o[0,255]

      if language_id !=c_language_id
         s= Sub.where(:sub=>o,:nam_id=>nam.id,:src_id=>src.id, :lng_id=>language_id,:start=>"#{start}",:stop=>"#{stop}",:clng_id=>c_language_id,:num=>num).first_or_create
      else
         s= Cap.where(:cap=>o,:nam_id=>nam.id,:src_id=>src.id, :lng_id=>language_id,:start=>"#{start}",:stop=>"#{stop}",:num=>num,:wcount=>wcount,:ccount=>ccount).first_or_create
      end
    end
  end
end
#imports caps (dotsub,lyricstraining, movies and tv)
task :assign_languages_to_names => [:environment] do #run after importing caps/subs
  print "about to truncate lngs_nams\n"
  ActiveRecord::Migration.execute("truncate lngs_nams;")
  nl=Hash.new()
  c=0
  print "about to run through each nam and its lngs\n"
  ActiveRecord::Migration.suppress_messages do
    Nam.all.each do |n|
      nl["#{n.id}-#{n.lng_id}"]=1
      ActiveRecord::Migration.execute("select lng_id from subs where nam_id=#{n.id} group by lng_id;").each do |s|
        c+=1
        print "#{c} #{n.id} #{s[0]}\n" if c%100 == 2
        nl["#{n.id}-#{s[0]}"]=1
      end
    end
  end #end suppress
  print "#{nl.size} ....\n"
  count=0
  ActiveRecord::Migration.suppress_messages do
    nl.each do |k,v|
      count+=1
      print "inserting into lngs nams: count:#{count} #{nam_id}\n" if count%2==500
      (nam_id,lng_id) = k.split(/-/)
    #  print "#{lng_id} --- #{nam_id}\n"
      ActiveRecord::Migration.execute("insert into lngs_nams(lng_id,nam_id)values(#{lng_id},#{nam_id})")
#      print "#{name_id} #{language_id}\n"
    end
  end
  print "done with lng_nam\n"
#  if ENV['RAILS_ENV'].match(/production/) then
#    Rails.cache.clear()
#  end
end
