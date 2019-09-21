#encoding: utf-8

#rake import_verbs language=spanish --trace
#rake import_verbs language=french --trace
task :import_verbs => [:environment] do
  language_id= Lng.where(%Q/lng="#{ENV['language']}"/).first.id
  basedir = Rails.root.to_s + "/lib/text_files"
  file = File.new(basedir +"/#{ENV['language']}_verbs.txt", "r")
  language = Lng.find(language_id)
  moods       = Hash.new()
  verbs       = Hash.new()
  tenses      = Hash.new()
  pronouns    = Hash.new()
  mood_p = Hash.new()
  tiempo_p= Hash.new()
  tense_p=Hash.new()
  pronoun_p=Hash.new()
  tiempos       = Hash.new()
  conjugations= Hash.new()
  cm=Hash.new()
  cmt=Hash.new()
  cmktp=Hash.new()


  if ENV['language']=="spanish" then
    mood_p["verboide"]    = 1
    mood_p["indicativo"]  = 2
    mood_p["imperativo"]  = 3
    mood_p["condicional"] = 4
    mood_p["subjuntivo"]  = 5
    tense_p["presente"]                = 1
    tense_p["imperfecto"]              = 2
    tense_p["pretérito"]               = 3
    tense_p["pretérito perfecto"]      = 4
    tense_p["pretérito anterior"]      = 5
    tense_p["pluscuamperfecto"]        = 6
    tense_p["futuro simple"]           = 7
    tense_p["futuro perfecto"]         = 8
    tense_p["infinitivo"]              = 9
    tense_p["gerundio"]                = 10
    tense_p["condicional simple"]      = 11
    tense_p["condicional perfecto"]    = 12
    tense_p["participio"]              = 13
    tense_p["imperativo"]              = 13



    tiempo_p["presente"]                = 1
    tiempo_p["imperfecto"]              = 2

    pronoun_p["yo"]         = 1
    pronoun_p["me"]         = 2
    pronoun_p["tú"]         = 3
    pronoun_p["te"]         = 4
    pronoun_p["usted"]      = 5
    pronoun_p["el"] = 6
    pronoun_p["ella"] = 7
    pronoun_p["se"] = 8
    pronoun_p["ud"] = 9

    pronoun_p["nosotros"]   = 10
    pronoun_p["nos"]    = 11
    pronoun_p["vosotros"]   = 12
    pronoun_p["ustedes"]    = 23
    pronoun_p["ellos"]= 10
    pronoun_p["ellas"]=11
    pronoun_p["uds"] = 12
  end

  if ENV['language']=="french" then
    mood_p["infinitif"]    = 1
    mood_p["participe"]    = 2
    mood_p["indicatif"]  = 3
    mood_p["subjonctif"]  = 4
    mood_p["conditionnel"] = 5
    mood_p["impératif"]  = 6


    tense_p["infinitif"]                = 1
    tense_p["participe présent"]                = 2
    tense_p["participe passé"]                = 3

    tense_p["présent"]                = 4
    tense_p["imparfait"]              = 5
    tense_p["passé simple"]      = 6
    tense_p["futur simple"]      = 7
    tense_p["passé composé"]        = 8
    tense_p["plus-que-parfait"]           = 9
    tense_p["passé antérieur"]         = 10
    tense_p["futur antérieur"]              = 11
    tense_p["passé"]                = 12
    tense_p["impératif"]                = 13


    pronoun_p["j'"]     = 1
    pronoun_p["tu"]     = 2
    pronoun_p["usted"]  = 3
    pronoun_p["il"]     = 7
    pronoun_p["elle"]   = 8
    pronoun_p["on"]     = 9
    pronoun_p["nous"]   = 10
    pronoun_p["vous"]   = 11
    pronoun_p["ils"]    = 12
    pronoun_p["elles"]  = 13
  end

  while (line = file.gets)
    line = line.gsub(/\n/,'')
    line = line.gsub(/\r/,'')
    line = line.gsub(/\t\s+/,"\t")
    line.downcase!
    (verb,conjugation,mood,tense,pronoun,tiempo)=line.split(/\t/)


    if pronoun then
#print "-#{pronoun}-\n"
      pronoun = "yo"                       if pronoun.match(/yo/)
      pronoun = "tú:tu:vos"                if pronoun.match(/tu/)
      pronoun = "él:el:ella:ud:usted"         if pronoun.match(/el\/ella\/ud/)
      pronoun = "nosotros:nos"                if pronoun.match(/nosotros/)
      pronoun = "ellos:ellas:uds:ustedes:se"  if pronoun.match(/ellos\/ellas\/uds/)
      pronoun = "usted"                       if pronoun.match (/usted/)
      pronoun = "ustedes"                     if pronoun.match (/ustedes/)
      pronoun = "vosotros"                    if pronoun.match(/vosotros/)

       pronoun = "je:j'"                          if pronoun.match(/je/)
       pronoun = "il:elle:on"                     if pronoun.match(/il\/elle\/on/)
       pronoun = "ellos:ellas:uds:ustedes:se:no"  if pronoun.match(/ellos\/ellas\/uds/)
       pronoun = "ils:elles"                      if pronoun.match (/ils\/elles/)
    else
      print "no pronoun #{line}\n"
    end

    moods[mood]                   = 1
    tenses["#{mood}*#{tense}"]    = 1
   # print "#{verb} #{conjugation} #{mood} #{tense} -- #{tiempo} ttttt\n"
    pronouns[pronoun]             = 1 if pronoun

    if ENV['language']=="spanish" then
     tiempos[tiempo]   = 1 if tiempo
    end

    verbs[verb]      = 1
    cmktp["#{conjugation}::#{mood}::#{tiempo}::#{tense}::#{pronoun}"] = verb if ENV['language']=="spanish" #conjugation-mood-tense
    cmktp["#{conjugation}::#{mood}::#{tense}::#{pronoun}"] = verb if ENV['language']!="spanish" #conjugation-mood-tense
#    print "#{conjugation}::#{mood}::#{tense}\n" if ENV['language']!="spanish" #conjugation-mood-tense


  end
#  print "#{cmkt.size}\n"
  stored_moods=Hash.new()
  moods.each do |k,v|
    if mood_p[k] then
      m = Mood.where(%Q/mood="#{k}"/).first
      m = Mood.new(:mood=>"#{k}", :lng_id=>language_id, :priority=>mood_p[k]).save if !m
      m = Mood.where(%Q/mood="#{k}"/).first
      stored_moods["#{k}"] = m.id if m
    end
  end

  if ENV['language']=="spanish" then
    stored_tiempos=Hash.new()
    tiempos.each do |k,v|
      if k.size>0 then
        tiempo  =  Tiempo.where(%Q/tiempo="#{k}"/).first
        tiempo  =  Tiempo.new(:tiempo=>"#{k}", :lng_id=>language_id,:priority=>tiempo_p[k]).save if !tiempo
        tiempo  =  Tiempo.where(%Q/tiempo="#{k}"/).first
        stored_tiempos["#{k}"] = tiempo.id if tiempo
      end
    end
  end
  stored_tenses=Hash.new()
  tenses.each do |k,v|
    (mood,tense) = k.split("*")
#    print "#{mood} #{tense} xxxxx\n"
    if tense_p[tense] then
 #     print "aaaaq #{tense} #{stored_moods[mood]}\n"
      t =  Tense.where(%Q/tense= "#{tense}" and mood_id="#{stored_moods[mood]}"/).first
      t =  Tense.new(:tense=>"#{tense}", :lng_id=>language_id,:mood_id=>stored_moods[mood], :priority=>tense_p[tense]).save if !t
      t =  Tense.where(%Q/tense = "#{tense}" and mood_id = "#{stored_moods[mood]}"/).first
      stored_tenses["#{mood}-#{tense}"]= t.id
    end
  end

  stored_pronouns=Hash.new()
  pronouns.each do |k,v|
    # p =  Pronoun.where(%Q/pronoun="#{k}"/).first
    # p = Pronoun.new(:pronoun=>"#{k.downcase}", :language_id=>language_id, :priority=>pronoun_p[k]).save if !p
    # p = Pronoun.where(%Q/pronoun="#{k}"/).first
    stored_pronouns["#{k}"]= p.id if p
  end
  stored_verbs=Hash.new()
  verbs.each do |k,v|
  #  print "#{k} #{v} .....\n"
    v =  Verb.where(%Q/verb="#{k}"/).first
    v =  Verb.new(:verb=>"#{k}", :lng_id=>language_id).save! if !v
    v =  Verb.where(%Q/verb="#{k}"/).first

#    print "#{verb}\n" if v
    stored_verbs["#{k}"]= v.id if v
  end

  stored_conjugations=Hash.new()
  ActiveRecord::Migration.suppress_messages do
     cmktp.each do |k,v|
       if ENV['language']=="spanish"
         (conjugation,mood,tiempo,tense,pronoun) = k.split("::")
         mood_id    = stored_moods[mood]
         tiempo_id  = stored_tiempos[tiempo] || 0
         tiempo_id  =  0 if ENV['language']!="spanish"
         tense_id   = stored_tenses["#{mood}-#{tense}"]
         verb_id    = stored_verbs[v]

      (conjugation,mood,tiempo,tense) = k.split("::")
      createdAt = Time.now.strftime('%Y-%m-%d %H:%M:%S')
      ActiveRecord::Migration.execute("insert into cons (con,created_at, updated_at,verb_id,mood_id,tiempo_id,tense_id,lng_id,pronoun) values('#{conjugation}', '#{createdAt}', '#{createdAt}',#{verb_id},#{mood_id},#{tiempo_id},#{tense_id},#{language_id},\"#{pronoun || '0'}\");") if ENV['language']=="spanish"
    else
#    print "#{k}\n"
         (conjugation,mood,tense,pronoun) = k.split("::")
         mood_id    = stored_moods[mood]
         tense_id   = stored_tenses["#{mood}-#{tense}"]
         verb_id    = stored_verbs[v]
      (conjugation,mood,tense) = k.split("::")
      temp_conjugation = conjugation.gsub(/'/, "\\\\'")
      if !conjugation.match(/<img src/) then
      ActiveRecord::Migration.execute("insert into cons (con,verb_id,mood_id,tense_id,lng_id,pronoun) values('#{temp_conjugation}',#{verb_id},#{mood_id},#{tense_id},#{language_id},\"#{pronoun}\");") if ENV['language']=="french"
    end
    end

    end
  end
  print "\n#{conjugations.size}\n#{cm.size}\n#{cmktp.size}\n"
  file.close
end
