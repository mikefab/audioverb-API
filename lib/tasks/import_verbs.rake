#rake import_verbs language=por_br --trace
#rake import_verbs language=kor --trace
# rake import_verbs language=tur --trace
task :import_verbs => [:environment] do
  print "Starting"
  language_id= Lng.where(cod: ENV['cod']).first.id
  language= Lng.where(cod: ENV['cod']).first.lng
  ActiveRecord::Migration.execute("delete from verbs where lng_id=#{language_id};")
  ActiveRecord::Migration.execute("delete from cons where lng_id=#{language_id};")
  basedir = Rails.root.to_s + "/lib/text_files/verbs"
  file = File.new(basedir +"/#{language}_verbs.txt", "r")
  language = Lng.find(language_id)
  moods       = Hash.new()
  verbs       = Hash.new()
  tenses      = Hash.new()
  pronouns    = Hash.new()
  mood_p = Hash.new()
  tense_p=Hash.new()
  pronoun_p=Hash.new()
  conjugations= Hash.new()
  cm=Hash.new()
  cmtp=Hash.new()


  if ENV['language']=="portuguese" then    # mood_p["subjuntivo"]  = 5
    tense_p["Present"] = 1
    tense_p["Perfeito"] = 2
    tense_p["Imperfeito"] = 3
    tense_p["Mais-que-perfeito"] = 4
    tense_p["Futuro"] = 5
    tense_p["Pretérito"] = 6
    tense_p["Present"] = 7
    tense_p["Perfeito"] = 8
    tense_p["Imperfeito"] = 9
    tense_p["Mais-que-perfeito"] = 10
    tense_p["Futuro"] = 11
    tense_p["Condicional"] = 12
    tense_p["Perfeito"] = 13
    mood_p["Indicative"] = 14
    mood_p["Subjuntivo"] = 15
    mood_p["Conditional"] = 16
    mood_p["Infinitivo"] = 17
    mood_p["Participio"] = 16
    mood_p["Gerundio"] = 17
  end

  while (line = file.gets)
    line = line.gsub(/\n/,'')
    line = line.gsub(/\r/,'')
    line = line.gsub(/\t\s+/,"\t")
    line.downcase!
    (verb,mood, tense,conjugation,pronoun)=line.split(/,/)
    if line.match(/^,,/) then
      verb = nil
    end
    if verb then
      
      if pronoun then
        pronoun = "eles:elas:vocês:se"  if pronoun.match(/^eles$/)
        pronoun = "ele:ela:você:se" if pronoun.match(/^ele$/)
      end

      #print "#{verb}, #{mood}, #{tense}, #{conjugation},#{pronoun},'\n'"
      moods[mood] = 1
      tenses["#{mood}*#{tense}"] = 1
     # print "#{verb} #{conjugation} #{mood} #{tense} -- #{tiempo} ttttt\n"
      pronouns[pronoun] = 1 if pronoun
      verbs[verb] = 1
      cmtp["#{conjugation}::#{mood}::#{tense}::#{pronoun}"] = verb  #conjugation-mood-tense
    else
      print "NOT #{line}"
    end
  end
  print "Adding moods"
  print moods
  stored_moods=Hash.new()
  moods.each do |k,v|
#    if mood_p[k] then
      puts "#{k} #{mood_p[k]} #{language_id}"
      m = Mood.where(mood: k, lng_id: language_id).first
      m = Mood.new(:mood=>"#{k}", :lng_id=>language_id, :priority=>mood_p[k]).save if !m
      m = Mood.where(mood: k, lng_id: language_id).first
      stored_moods["#{k}"] = m.id if m
#    end
  end

  stored_tenses=Hash.new()
  tenses.each do |k,v|
    (mood,tense) = k.split("*")

    # if tense_p[tense] then
      t =  Tense.where(tense: tense, mood_id: stored_moods[mood], lng_id: language_id).first
      t =  Tense.new(:tense=>"#{tense}", :lng_id=>language_id,:mood_id=>stored_moods[mood], :priority=>tense_p[tense]).save if !t
      t =  Tense.where(tense: tense, mood_id: stored_moods[mood], lng_id: language_id).first
      stored_tenses["#{mood}-#{tense}"]= t.id
    # end
  end


  stored_verbs=Hash.new()
  verbs.each do |k,v|
    v =  Verb.where(verb: k, lng_id: language_id).first
    v =  Verb.new(:verb=>"#{k}", :lng_id=>language_id).save! if !v
    v =  Verb.where(verb: k, lng_id: language_id).first
    stored_verbs["#{k}"]= v.id if v
  end

  stored_conjugations=Hash.new()
  createdAt = Time.now.strftime('%Y-%m-%d %H:%M:%S')
  ActiveRecord::Migration.suppress_messages do
    cmtp.each do |k,v|
     (conjugation,mood,tense,pronoun) = k.split("::")
     mood_id    = stored_moods[mood]
     tense_id   = stored_tenses["#{mood}-#{tense}"]
     verb_id    = stored_verbs[v]
     (conjugation,mood,tense) = k.split("::")
     temp_conjugation = conjugation.gsub(/'/, "\\\\'")
     #print "#{temp_conjugation}-\n"
     if !conjugation.match(/<img src/) then
       #print "insert into cons (con,verb_id,mood_id,tense_id,lng_id,pronoun) values('#{temp_conjugation}',#{verb_id},#{mood_id},#{tense_id},#{language_id},'#{pronoun}');"
       ActiveRecord::Migration.execute("insert into cons (con,verb_id,mood_id,tense_id,lng_id,pronoun) values('#{temp_conjugation}',#{verb_id},#{mood_id},#{tense_id},#{language_id},'#{pronoun}');")
     end
    end
  end
  print "\n#{conjugations.size}\n#{cmtp.size}\n"
  file.close
end
