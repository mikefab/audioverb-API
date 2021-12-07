#SPANISH!
#bundle exec rake create_clauses language=spa --trace
task :create_clauses => [:environment] do
  language_id = Lng.where(%Q/cod="#{ENV['language']}"/).first.id

  start       = ENV['start'] || 0 #for starting in the middle of caps
  cla_hash    = Hash.new()

  ignore_words = {
    "agua" => 1,
    "abogado" => 1,
    "así" => 1,
    "abajo" => 1,
    "anillo" => 1,
    "arma" => 1,
    "armas" => 1,
    "ayuda" => 1,
    "baja" => 1,
    "base" => 1,
    "bajo" => 1,
    "calle" => 1,
    "cambio" => 1,
    "casa" => 1,
    "casas" => 1,
    "caso" => 1,
    "centro" => 1,
    "cosa" => 1,
    "cosas" => 1,
    "como" => 1,
    "cuenta" => 1,
    "entre" => 1,
    "de" => 1,
    "forma" => 1,
    "idea" => 1,
    "importa" => 1,
    "multa" => 1,
    "para" => 1,
    "paso" => 1,
    "piso" => 1,
    "pregunta" => 1,
    "sobre" => 1,
    "sueño" => 1,
    "tarde" => 1,
    "tema" => 1,
    "trabajo" => 1,
    "una" => 1
  }

  # Get existing clas per lng
  Cla.where(:lng_id=>language_id).each do |c|
    cla_hash[c.cla] = c
  end

  Rake::Task["assign_languages_to_names"].execute

  conj_id             = Hash.new()
  seen                = Hash.new()
  moods               = Hash.new()
  tenses              = Hash.new()
  verbs               = Hash.new()
  pronoun             = Hash.new()
  cla_id_language_id  = Hash.new()
  cla_id              = Hash.new()
  i=0
  cap_id_cla_id = Hash.new()  # get all cap-cla ids from caps_clas

  #need to create an array of tenses per con
  con_hash_of_tenses= Hash.new()

  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Migration.execute("select cap_id,cla_id from caps_clas").each do |cc|
      cap_id_cla_id["#{cc[0]}^#{cc[1]}"]=1
    end
    ActiveRecord::Migration.execute("select con, mood_id, tense_id,verb_id,id,pronoun from cons where lng_id=#{language_id}").each do |j|
      temp="#{j[0]}^#{j[1]}^#{j[2]}" #conjugation-mood_id-tense_id
      if con_hash_of_tenses[j[0]] then
        con_hash_of_tenses[j[0]] << "#{j[1]}^#{j[2]}" #mood_id-tense_id #will need to run through this later before creating a new cap
      else
        con_hash_of_tenses[j[0]] = ["#{j[1]}^#{j[2]}"]
      end
      moods[temp]       = j[1]
      tenses[temp]      = j[2]
      verbs[temp]       = j[3]
      pronoun[temp]     = j[4]
      conj_id[j[0]]     = 1 # this needs to be just the clause (con), for compairing against word/word pair in cap loop
    end

  end#end suppress

  count=0

  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Migration.execute("select cla, id, mood_id, tense_id from clas where lng_id=#{language_id};").each do |c|
      count+=1
      print "#{count} seen size: #{seen.size}\n cla_id size: #{cla_id.size}" if count%1000==2
      seen["#{c[0]}^#{c[2]}^#{c[3]}"]=1 #cla-mood_id-tense_id for clas with multiple tense parents
      cla_id["#{c[0]}^#{c[2]}^#{c[3]}"]=c[1] # word=id
    end
  end #end suppress

  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Migration.execute("select cla_id, lng_id from clas_lngs").each do |cl|
      cla_id_language_id["#{cl[0]}^#{cl[1]}"]=1000
    end
  end #end suppress


  cla_id_cap_id=Hash.new()
  count=0

  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Migration.execute("select cap,id from caps where id >= #{start} and lng_id=#{language_id}").each do |c|
      count+=1
      temp_cap_id= c[1] #id
      c[0]=c[0].gsub(/(\(|\)|"|'|\?|\!|\.|,|\n|\r|^\s+|\s+$)/," ").downcase

      #split cap into words
      words = c[0].split(/\s+/)
      #loop through each word
      words.length.times do |i|
        puts "#{words[i]} !!"
        if i > 0 and conj_id["#{words[i-1]} #{words[i]}"] then  #"#{a[i-1]} #{a[i]}" <-- if this is a conjugation
          con_hash_of_tenses["#{words[i-1]} #{words[i]}"].each do |mood_id_tense_id|
            (mood_id,tense_id)= mood_id_tense_id.split(/\^/)
            unless seen["#{words[i-1]} #{words[i]}^#{mood_id_tense_id}"] then #so here
              w2=Cla.new(:cla=>"#{words[(i-1)]} #{words[i]}",:lng_id=>language_id, :mood_id=>mood_id,:tense_id=>tense_id, :verb_id=>verbs["#{words[(i-1)]} #{words[i]}^#{mood_id_tense_id}"])
              if w2.cla then #and w2.cla.match(/[a-zA-Z]/) then
                w2.save!
                cla_hash[w2.cla] = w2 #save this for later when looping at end for adding to title_list
                cla_id["#{w2.cla}^#{mood_id_tense_id}"]=w2.id #need to make this key "clause"-mood_id_tense_id
              end
              seen["#{words[i-1]} #{words[i]}^#{mood_id_tense_id}"]=1
            end #end of seen
#            cla_cap["#{a[i-1]} #{a[i]}::#{temp_cap_id}"]=1    if a[i]=~/[a-zA-Z]/ #this should be ok with multiple clauses
            cla_id_cap_id["#{words[i-1]} #{words[i]}^#{mood_id_tense_id}::#{temp_cap_id}"]=1    if words[i]=~/[a-zA-Z]/ #this should be ok with multiple clauses
          end #end of loop through con_hash_of_tenses
        elsif conj_id[words[i]] and !ignore_words[words[i]] then     #This single word is a conjugation
          con_hash_of_tenses[words[i]].each do |mood_id_tense_id|
            unless seen["#{words[i]}^#{mood_id_tense_id}"] then #It is the first instance of this conjugation-mood_id-tense_id
              (mood_id,tense_id)= mood_id_tense_id.split(/\^/)
              w = Cla.new(:cla=>words[i], :lng_id=>language_id, :mood_id=>mood_id,:tense_id=>tense_id, :verb_id=>verbs["#{words[i]}^#{mood_id_tense_id}"])
              if w.cla then#and w.cla.match(/[a-zA-Z]/) then
                w.save!
                cla_hash[w.cla] = w #save this for later when looping at end for adding to title_list
                cla_id["#{w.cla}^#{mood_id_tense_id}"]=w.id #need to make this key "clause"-mood_id_tense_id
              end
              seen["#{words[i]}^#{mood_id_tense_id}"]=1
            end #end if seen for single word
#           cla_cap["#{a[i]}^#{mood_id_tense_id}::#{temp_cap_id}"]=1  if a[i]=~/[a-zA-Z]/   #need to record cap id with clause id so can loop through cap's subs when storing languages_words
            cla_id_cap_id["#{words[i]}^#{mood_id_tense_id}::#{temp_cap_id}"]=1  #if words[i]=~/[a-zA-Z]/   #need to record cap id with clause id so can loop through cap's subs when storing languages_words
          end #end loop tenses
        end #end if word is conjugation
      end #end of looping through words in cap
    end #end of each cap
  end #end suppress

  clauses = Hash.new() #This is for looping through clauses found in caps and adding cat and title
  count=0
  createdAt = Time.now.strftime('%Y-%m-%d %H:%M:%S')

  ActiveRecord::Migration.suppress_messages do
    cla_id_cap_id.each do |k,v|   ##{cla-#{mood_id_tense_id} = 1
      count+=1
      print "#{count} #{k} #{v}\n" if count%100==2
      claid_capid = k.split("::") #claid_capid[0] is really cla-mood_id_tense_id
      #add native language record for languages_words
      unless cla_id_language_id["#{cla_id[claid_capid[0]]}^#{language_id}"]  #cla_id key is clause-mood_id_tense_id
        ActiveRecord::Migration.execute("insert into clas_lngs(cla_id,lng_id,olng_id)values(#{cla_id[claid_capid[0]]},#{language_id},#{language_id});")
        cla_id_language_id["#{cla_id[claid_capid[0]]}^#{language_id}"]=1
      end
      #add all languages that belong to cap's name
#      print "#{claid_capid[0]} #{claid_capid[1]} <-- cap id\n";
      cap = Cap.find(claid_capid[1])

      clause= k.split(/\^/)[0]
      clauses[clause] = 1

      #Add instance of cap_id_cla_id in cap_clas unless it already exists
      unless cap_id_cla_id["#{cap.id}^#{cla_id[claid_capid[0]]}"]
        ActiveRecord::Migration.execute("insert into caps_clas(cap_id,cla_id)values(#{cap.id},#{cla_id[claid_capid[0]]});")
        cap_id_cla_id["#{cap.id}^#{cla_id[claid_capid[0]]}"]=1
      end
    end #end of looping through word_cap
  end #end suppress

  clauses.each do |k,v|
    puts "#{k} - #{v} - #{cla_hash[k].to_s}"
    cla_hash[k].save
  end
end
