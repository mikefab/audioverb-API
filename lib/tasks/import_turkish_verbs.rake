#rake import_verbs language=por_br --trace
#rake import_verbs language=kor --trace
# rake import_verbs language=tur --trace
task :import_turkish_verbs=> [:environment] do
  print "Starting"
  language_id= Lng.where(cod: ENV['cod']).first.id
  language= Lng.where(cod: ENV['cod']).first.lng
  ActiveRecord::Migration.execute("delete from cons where lng_id=#{language_id};")
  basedir = Rails.root.to_s + "/lib/text_files/verbs"
  file = File.new(basedir +"/#{language}_verbs.txt", "r")
  language = Lng.find(language_id)
  moods       = Hash.new()
  tenses      = Hash.new()
  verbs      = Hash.new()

  Tense.where(lng_id: language_id).each do |tense|
    tenses[tense.tense] = tense.id
  end
  Mood.where(lng_id: language_id).each do |mood|
    moods[mood.mood] = mood.id
  end
  Verb.where(lng_id: language_id).each do |verb|
    verbs[verb.verb] = verb.id
  end


  c = 0
  while (line = file.gets)
    c+=1
    puts c if c%1000==0
    line = line.gsub(/\n/,'')
    line = line.gsub(/\r/,'')
    line = line.gsub(/\t\s+/,"\t")
    line.downcase!
    (verb,mood, tense,conjugation,pronoun)=line.split(/,/)
    #puts "#{verb},#{mood}, #{tense},#{conjugation},#{pronoun}"
    if line.match(/^,,/) then
      verb = nil
    end
    if verb then
#      puts "-#{conjugation}-,#{verbs[verb]},#{moods[mood]},#{tenses[mood]},#{language_id},#{pronoun}"
      if conjugation && verbs[verb] then
      ActiveRecord::Migration.suppress_messages do
          ActiveRecord::Migration.execute("insert into cons (con,verb_id,mood_id,tense_id,lng_id,pronoun) values(\"#{conjugation}\",#{verbs[verb]},#{moods[mood]},#{tenses[mood]},#{language_id},'#{pronoun}');")
      end
    end
    else
      print "NOT #{line}"
    end
  end


  # stored_conjugations=Hash.new()
  # createdAt = Time.now.strftime('%Y-%m-%d %H:%M:%S')
  # ActiveRecord::Migration.suppress_messages do
  #   cmtp.each do |k,v|
  #    (conjugation,mood,tense,pronoun) = k.split("::")
  #    mood_id    = stored_moods[mood]
  #    tense_id   = stored_tenses["#{mood}-#{tense}"]
  #    verb_id    = stored_verbs[v]
  #    (conjugation,mood,tense) = k.split("::")
  #    temp_conjugation = conjugation.gsub(/'/, "\\\\'")
  #    #print "#{temp_conjugation}-\n"
  #    if !conjugation.match(/<img src/) then
  #      #print "insert into cons (con,verb_id,mood_id,tense_id,lng_id,pronoun) values('#{temp_conjugation}',#{verb_id},#{mood_id},#{tense_id},#{language_id},'#{pronoun}');"
  #      ActiveRecord::Migration.execute("insert into cons (con,verb_id,mood_id,tense_id,lng_id,pronoun) values('#{temp_conjugation}',#{verb_id},#{mood_id},#{tense_id},#{language_id},'#{pronoun}');")
  #    end
  #   end
  # end
  # print "\n#{conjugations.size}\n#{cmtp.size}\n"
  file.close
end
