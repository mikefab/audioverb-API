#encoding: utf-8

#You should just have to do this once upon project creation
task :add_languages => [:environment] do
  Lng.seed_data
end


task :import_english_idioms => [:environment] do #why is this separate from import_english_verbs?
  language=Lng.find_by_cod('eng')
  basedir = Rails.root.to_s + "/lib/text_files"

  ['verbs', 'prepositions', 'expressions'].each do | word |

     file = File.new(basedir + "/idiomatic_#{word}.txt", "r")
     while (line = file.gets)
     line= line.gsub(/\n/,"")
     line= line.gsub(/\r/,"")
     puts line

     Ido.find_or_initialize_by(:ido=>line.downcase, :lng_id=>language.id, :kind=>word[0]).save!
     # c=c+1
   end
  end
end

task :import_english_tenses => [:environment] do #why is this separate from import_english_verbs?
  c=1
  language=Lng.find_by_cod('eng')

  tiempos=["infinitive","gerund","participle","past"]
  tiempos.each do |tiempo|
    Tiempo.find_or_initialize_by(:tiempo=>tiempo, :lng_id=>language.id, :priority=>c).save!
    c=c+1
  end
  c=1
  basedir = Rails.root.to_s + "/lib/text_files"
   file = File.new(basedir +'/english_tenses.txt', "r")
   while (line = file.gets)
   line= line.gsub(/\n/,"")
   line= line.gsub(/\r/,"")
   line.downcase!
   (tense,example,explanation)=line.split(/\t/)

   # t =  Tense.find(:first,:conditions=>["tense=?","#{tense}"])
   # t =  Tense.new(:tense=>"#{tense}", :lng_id=>language.id, :priority=>c).save if !t

       Tense.find_or_initialize_by(:tense=>tense, :lng_id=>language.id, :priority=>c).save!
   c=c+1
  end
end

task :import_english_verbs => [:environment] do
  basedir = Rails.root.to_s + "/lib/text_files"
  file = File.new(basedir +"/english_verbs.txt", "r")
  language_id=Lng.find_by_cod('eng').id

  ActiveRecord::Migration.execute("delete from cons where lng_id = #{language_id};")
  ActiveRecord::Migration.execute("delete from verbs where lng_id = #{language_id};")
  ActiveRecord::Migration.execute("delete from tiempos where lng_id = #{language_id};")

  while (line = file.gets)
    line = line.gsub(/\n/,'')
    line = line.gsub(/\r/,'')
    line = line.gsub(/\t\s+/,"\t")
    line.downcase!
    (verb,conjugation,tiempo)=line.split(/\t/)
    v=Verb.find_or_initialize_by(:verb=>verb,:lng_id=>language_id)
    v.save!

    t =  Tiempo.find_or_initialize_by(:tiempo=>tiempo,:lng_id=>language_id)
    t.save!
    c=Con.new(:verb_id=>v.id,:lng_id=>language_id,:tiempo_id=>t.id,:con=>conjugation).save!
  end
end


# #rake import_verbs language=spanish --trace
# #rake import_verbs language=french --trace
# task :import_verbs => [:environment] do
#   language_id= Lng.where(%Q/lng="#{ENV['language']}"/).first.id
#   basedir = Rails.root.to_s + "/lib/text_files"
#   file = File.new(basedir +"/#{ENV['language']}_verbs.txt", "r")
#   language = Lng.find(language_id)
#   moods       = Hash.new()
#   verbs       = Hash.new()
#   tenses      = Hash.new()
#   pronouns    = Hash.new()
#   mood_p = Hash.new()
#   tiempo_p= Hash.new()
#   tense_p=Hash.new()
#   pronoun_p=Hash.new()
#   tiempos       = Hash.new()
#   conjugations= Hash.new()
#   cm=Hash.new()
#   cmt=Hash.new()
#   cmktp=Hash.new()
#
#
#   if ENV['language']=="spanish" then
#     # mood_p["verboide"]    = 1
#     # mood_p["indicativo"]  = 2
#     # mood_p["imperativo"]  = 3
#     # mood_p["condicional"] = 4
#     # mood_p["subjuntivo"]  = 5
#     tense_p["presente"]                = 1
#     tense_p["imperfecto"]              = 2
#     tense_p["pretérito"]               = 3
#     tense_p["pretérito perfecto"]      = 4
#     tense_p["pretérito anterior"]      = 5
#     tense_p["pluscuamperfecto"]        = 6
#     tense_p["futuro simple"]           = 7
#     tense_p["futuro perfecto"]         = 8
#     tense_p["infinitivo"]              = 9
#     tense_p["gerundio"]                = 10
#     tense_p["condicional simple"]      = 11
#     tense_p["condicional perfecto"]    = 12
#     tense_p["participio"]              = 13
#     tense_p["imperativo"]              = 13
#
#     # tiempo_p["presente"]                = 1
#     # tiempo_p["imperfecto"]              = 2
#
#     pronoun_p["yo"]         = 1
#     pronoun_p["me"]         = 2
#     pronoun_p["tú"]         = 3
#     pronoun_p["te"]         = 4
#     pronoun_p["usted"]      = 5
#     pronoun_p["el"] = 6
#     pronoun_p["ella"] = 7
#     pronoun_p["se"] = 8
#     pronoun_p["ud"] = 9
#
#     pronoun_p["nosotros"]   = 10
#     pronoun_p["nos"]    = 11
#     pronoun_p["vosotros"]   = 12
#     pronoun_p["ustedes"]    = 23
#     pronoun_p["ellos"]= 10
#     pronoun_p["ellas"]=11
#     pronoun_p["uds"] = 12
#   end
#
#   if ENV['language']=="french" then
#     mood_p["infinitif"] = 1
#     mood_p["participe"] = 2
#     mood_p["indicatif"] = 3
#     mood_p["subjonctif"] = 4
#     mood_p["conditionnel"] = 5
#     mood_p["impératif"]  = 6
#
#     tense_p["infinitif"] = 1
#     tense_p["participe présent"] = 2
#     tense_p["participe passé"] = 3
#
#     tense_p["présent"]  = 4
#     tense_p["imparfait"] = 5
#     tense_p["passé simple"] = 6
#     tense_p["futur simple"] = 7
#     tense_p["passé composé"] = 8
#     tense_p["plus-que-parfait"] = 9
#     tense_p["passé antérieur"] = 10
#     tense_p["futur antérieur"] = 11
#     tense_p["passé"] = 12
#     tense_p["impératif"] = 13
#
#
#     pronoun_p["j'"]     = 1
#     pronoun_p["tu"]     = 2
#     pronoun_p["usted"]  = 3
#     pronoun_p["il"]     = 7
#     pronoun_p["elle"]   = 8
#     pronoun_p["on"]     = 9
#     pronoun_p["nous"]   = 10
#     pronoun_p["vous"]   = 11
#     pronoun_p["ils"]    = 12
#     pronoun_p["elles"]  = 13
#   end
#
#   while (line = file.gets)
#     line = line.gsub(/\n/,'')
#     line = line.gsub(/\r/,'')
#     line = line.gsub(/\t\s+/,"\t")
#     line.downcase!
#     (verb,conjugation,mood,tense,pronoun,tiempo)=line.split(/\t/)
#
#
#     if pronoun then
# #print "-#{pronoun}-\n"
#       pronoun = "yo"                       if pronoun.match(/yo/)
#       pronoun = "tú:tu:vos"                if pronoun.match(/tu/)
#       pronoun = "él:el:ella:ud:usted"         if pronoun.match(/el\/ella\/ud/)
#       pronoun = "nosotros:nos"                if pronoun.match(/nosotros/)
#       pronoun = "ellos:ellas:uds:ustedes:se"  if pronoun.match(/ellos\/ellas\/uds/)
#       pronoun = "usted"                       if pronoun.match (/usted/)
#       pronoun = "ustedes"                     if pronoun.match (/ustedes/)
#       pronoun = "vosotros"                    if pronoun.match(/vosotros/)
#
#        pronoun = "je:j'"                          if pronoun.match(/je/)
#        pronoun = "il:elle:on"                     if pronoun.match(/il\/elle\/on/)
#        pronoun = "ellos:ellas:uds:ustedes:se:no"  if pronoun.match(/ellos\/ellas\/uds/)
#        pronoun = "ils:elles"                      if pronoun.match (/ils\/elles/)
#     else
#       print "no pronoun #{line}\n"
#     end
#
#     moods[mood]                   = 1
#     tenses["#{mood}*#{tense}"]    = 1
#    # print "#{verb} #{conjugation} #{mood} #{tense} -- #{tiempo} ttttt\n"
#     pronouns[pronoun]             = 1 if pronoun
#
#     if ENV['language']=="spanish" then
#      tiempos[tiempo]   = 1 if tiempo
#     end
#
#     verbs[verb]      = 1
#     cmktp["#{conjugation}::#{mood}::#{tiempo}::#{tense}::#{pronoun}"] = verb if ENV['language']=="spanish" #conjugation-mood-tense
#     cmktp["#{conjugation}::#{mood}::#{tense}::#{pronoun}"] = verb if ENV['language']!="spanish" #conjugation-mood-tense
# #    print "#{conjugation}::#{mood}::#{tense}\n" if ENV['language']!="spanish" #conjugation-mood-tense
#
#
#   end
# #  print "#{cmkt.size}\n"
#   stored_moods=Hash.new()
#   moods.each do |k,v|
#     if mood_p[k] then
#       m = Mood.where(%Q/mood="#{k}"/).first
#       m = Mood.new(:mood=>"#{k}", :lng_id=>language_id, :priority=>mood_p[k]).save if !m
#       m = Mood.where(%Q/mood="#{k}"/).first
#       stored_moods["#{k}"] = m.id if m
#     end
#   end
#
#   if ENV['language']=="spanish" then
#     stored_tiempos=Hash.new()
#     tiempos.each do |k,v|
#       if k.size>0 then
#         tiempo  =  Tiempo.where(%Q/tiempo="#{k}"/).first
#         tiempo  =  Tiempo.new(:tiempo=>"#{k}", :lng_id=>language_id,:priority=>tiempo_p[k]).save if !tiempo
#         tiempo  =  Tiempo.where(%Q/tiempo="#{k}"/).first
#         stored_tiempos["#{k}"] = tiempo.id if tiempo
#       end
#     end
#   end
#   stored_tenses=Hash.new()
#   tenses.each do |k,v|
#     (mood,tense) = k.split("*")
# #    print "#{mood} #{tense} xxxxx\n"
#     if tense_p[tense] then
#  #     print "aaaaq #{tense} #{stored_moods[mood]}\n"
#       t =  Tense.where(%Q/tense= "#{tense}" and mood_id="#{stored_moods[mood]}"/).first
#       t =  Tense.new(:tense=>"#{tense}", :lng_id=>language_id,:mood_id=>stored_moods[mood], :priority=>tense_p[tense]).save if !t
#       t =  Tense.where(%Q/tense = "#{tense}" and mood_id = "#{stored_moods[mood]}"/).first
#       stored_tenses["#{mood}-#{tense}"]= t.id
#     end
#   end
#
#   stored_pronouns=Hash.new()
#   pronouns.each do |k,v|
#     # p =  Pronoun.where(%Q/pronoun="#{k}"/).first
#     # p = Pronoun.new(:pronoun=>"#{k.downcase}", :language_id=>language_id, :priority=>pronoun_p[k]).save if !p
#     # p = Pronoun.where(%Q/pronoun="#{k}"/).first
#     stored_pronouns["#{k}"]= p.id if p
#   end
#   stored_verbs=Hash.new()
#   verbs.each do |k,v|
#   #  print "#{k} #{v} .....\n"
#     v =  Verb.where(%Q/verb="#{k}"/).first
#     v =  Verb.new(:verb=>"#{k}", :lng_id=>language_id).save! if !v
#     v =  Verb.where(%Q/verb="#{k}"/).first
#
# #    print "#{verb}\n" if v
#     stored_verbs["#{k}"]= v.id if v
#   end
#
#   stored_conjugations=Hash.new()
#   createdAt = Time.now.strftime('%Y-%m-%d %H:%M:%S')
#   ActiveRecord::Migration.suppress_messages do
#      cmktp.each do |k,v|
#        if ENV['language']=="spanish"
#          (conjugation,mood,tiempo,tense,pronoun) = k.split("::")
#          mood_id    = stored_moods[mood]
#          tiempo_id  = stored_tiempos[tiempo] || 0
#          tiempo_id  =  0 if ENV['language']!="spanish"
#          tense_id   = stored_tenses["#{mood}-#{tense}"]
#          verb_id    = stored_verbs[v]
#
#       (conjugation,mood,tiempo,tense) = k.split("::")
#
#       ActiveRecord::Migration.execute("insert into cons (con,verb_id,mood_id,tiempo_id,tense_id,lng_id,pronoun) values('#{conjugation}',#{verb_id},#{mood_id},#{tiempo_id},#{tense_id},#{language_id},\"#{pronoun || '0'}\");") if ENV['language']=="spanish"
#     else
# #    print "#{k}\n"
#          (conjugation,mood,tense,pronoun) = k.split("::")
#          mood_id    = stored_moods[mood]
#          tense_id   = stored_tenses["#{mood}-#{tense}"]
#          verb_id    = stored_verbs[v]
#       (conjugation,mood,tense) = k.split("::")
#       temp_conjugation = conjugation.gsub(/'/, "\\\\'")
#       if !conjugation.match(/<img src/) then
#       ActiveRecord::Migration.execute("insert into cons (con,verb_id,mood_id,tense_id,lng_id,pronoun) values('#{temp_conjugation}',#{verb_id},#{mood_id},#{tense_id},#{language_id},\"#{pronoun}\");") if ENV['language']=="french"
#     end
#     end
#
#     end
#   end
#   print "\n#{conjugations.size}\n#{cm.size}\n#{cmktp.size}\n"
#   file.close
# end

task :import_chinese_grams => [:environment] do
  # Imports monograms and bigrams with frequency statistics from grams.txt into vocs table.
  # Can assume that if we already have a word in the words table, that we have all of its definitions
  chinese_lng_id = Lng.where(cod:  'chi_hans')[0].id

  basedir = Rails.root.to_s + "/lib/text_files"
#  {"monograms" => 1, "bigrams" => 2}.each do |k, v|
  {"bigrams" => 2}.each do |k, v|
    vocs=Hash.new()
    ActiveRecord::Migration.execute("select id, voc from vocs where gram = #{v}").each do |voc|
      vocs[voc[1]] = voc[0]
    end
    file  = File.new(basedir +"/#{k}.txt", "r")
    count = 0

    ActiveRecord::Migration.suppress_messages do
      while (line = file.gets)
        line                   =  line.gsub(/(\n|\r)/,"")
        (rank, voc, raw, freq) =  line.split(/\t/)
        count+=1
        print "#{rank} #{raw} #{freq} #{voc}\n" if count%500==2
        unless vocs[voc]  then
          voc = Voc.create(:voc=>voc,:raw=>raw, :rank=>rank,:freq=>freq,:lng_id=>chinese_lng_id,:gram=>v)
          vocs[voc.voc] = voc.id
        end
      end
    end
  end
end

# Imports list of kanji with pinyin
task :import_kanji => [:environment] do
#  require 'ting/string'
  pinyin_hash    = Hash.new
  kanji_pinyin   = Hash.new
  entry_hash     = Hash.new #entry - defs
  basedir = Rails.root.to_s + "/lib/text_files"
  file    = File.new(basedir +"/cedict_ts.u8", "r")
  while (line = file.gets)
    m =  /^(.+?)(\s+)(.+?)(\s+)(\[)(.+?)(\])(\s+\/)(.+?)$/.match line
    is_idiom = line.match(/\(idiom\)/) ? true : false
    unless m.nil?
      # m[3] is the first simplified character. m[6] is the numeric pinyin
     simplified = m[3]
     pinyin     = m[6]
     entry_hash["#{simplified}-#{pinyin}-#{is_idiom}"] = m[9]       # m[3] is the first simplified character. m[6] is the numeric pinyin
     simplified.gsub(/\s+/,"").split(//).each_with_index do |zi, i|
       kanji_pinyin["#{zi}-#{pinyin.split(/ /)[i]}"] = 1
     end
    end
  end
  c=0
  puts "Done reading file"

  # Loop throuth hash of kanji-pinyin and create kanjis
  kanji_pinyin.each do |k,v|
    kanji, pinyin = k.split(/-/)
    Kanji.find_or_initialize_by(kanji: kanji, pinyin: PinyinToneConverter.number_to_utf8(pinyin)).save!
  end

   entry_hash.each do |entry, definitions|
    # entry:  伤口-shang1 definitions: kou3 wound/cut/
    entry = entry.split(/-/)
    c+=1

    next unless entry[1].split(/ /).first.match(/[0-9]/)
    kanji = Kanji.where(kanji: entry[0].split(//).first, pinyin: PinyinToneConverter.number_to_utf8(entry[1].split(/ /).first)).first
    entry = Entry.find_or_initialize_by(
      entry: entry[0],
      kanji_id: kanji.id,
      pinyin:PinyinToneConverter.number_to_utf8(entry[1]),
      is_idiom: entry[2]
    )
    entry.save!
    #defs  = definitions.split("/")
    # defs.each do |definition|
    #   next if definition.match(/\r/)
    #   definition = Def.find_or_initialize_by(def: definition, entry_id: entry.id, kanji_id: kanji.id)
    #   puts "DEF: #{c} #{kanji.kanji} #{definition.def}" if c%500 == 0
    #   definition.save!
    # end
  end
end

# Imports list of kanji with pinyin
#bundle exec rake imoprt_hsk RAILS_ENV=production --trace
task :import_hsk => [:environment] do
  # require 'ting/string'
  frequency = nil
  basedir = Rails.root.to_s + "/lib/text_files"
  file    = File.new(basedir +"/hsk.csv", "r")
  while (line = file.gets)
    ary = line.split(/,/)
    #puts Voc.where(voc: ary[1]).length
    puts "#{ary[1]} #{ary[0]}"
    if ary[0].match(/\d/)
      voc = Voc.where(voc: ary[1]).first
      if voc
        frequency = voc.freq
        rank      = voc.rank
        raw       = voc.raw
        voc.update(level: ary[0])
      else
        Voc.find_or_initialize_by(voc: ary[1], freq: frequency, lng_id: 81, rank: rank, raw: raw, level: ary[0]).save!
      end
    end
  end
end
