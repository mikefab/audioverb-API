#rake import_verbs language=por_br --trace
#rake import_verbs language=kor --trace
# rake import_verbs language=tur --trace
task :import_turkish_tenses => [:environment] do
  print "Starting"
  language_id= Lng.where(cod: ENV['cod']).first.id
  language= Lng.where(cod: ENV['cod']).first.lng
  ActiveRecord::Migration.execute("delete from moods where lng_id=#{language_id};")
  ActiveRecord::Migration.execute("delete from tenses where lng_id=#{language_id};")
  ActiveRecord::Migration.execute("delete from verbs where lng_id=#{language_id};")
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

  c = 0
  while (line = file.gets)
    c+=1
    puts c if c%100==0
    line = line.gsub(/\n/,'')
    line = line.gsub(/\r/,'')
    line = line.gsub(/\t\s+/,"\t")
    line.downcase!
    (verb,mood, tense,conjugation,pronoun)=line.split(/,/)
    if line.match(/^,,/) then
      verb = nil
    end
    if verb then
      moods[mood] = 1
      tenses["#{mood}*#{mood} #{tense}"] = 1
      verbs[verb] = 1
    else
      print "NOT #{line}"
    end
  end
  print "Adding moods"
  print "#{moods.length} #{tenses.length} #{verbs.length}"
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
      t =  Tense.where(tense: mood, mood_id: stored_moods[mood], lng_id: language_id).first
      t =  Tense.new(:tense=>"#{mood}", :lng_id=>language_id,:mood_id=>stored_moods[mood], :priority=>tense_p[tense]).save if !t
      t =  Tense.where(tense: mood, mood_id: stored_moods[mood], lng_id: language_id).first
      stored_tenses["#{mood}-#{mood}"]= t.id
    # end
  end


  stored_verbs=Hash.new()
  verbs.each do |k,v|
    v =  Verb.where(verb: k, lng_id: language_id).first
    v =  Verb.new(:verb=>"#{k}", :lng_id=>language_id).save! if !v
    v =  Verb.where(verb: k, lng_id: language_id).first
    stored_verbs["#{k}"]= v.id if v
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
