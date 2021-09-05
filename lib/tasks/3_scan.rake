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
  tiempos             = Hash.new()
  verbs               = Hash.new()
  movie_title         = String.new() #used for storing movie's title, later used in adding title to clauses.
  pronoun             = Hash.new()
  cla_id_language_id  = Hash.new()
  cla_id              = Hash.new()
  i=0
  cap_id_cla_id = Hash.new()  # get all cap-cla ids from caps_clas
  id_src        = Hash.new()  # Ideally a caption's source will be a tag, but for now it's an attribute of the caption.

  Src.all.each do |s|
    id_src[s.id] = s.src
  end

  #need to create an array of tenses per con
  con_hash_of_tenses= Hash.new()

  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Migration.execute("select cap_id,cla_id from caps_clas").each do |cc|
      cap_id_cla_id["#{cc[0]}-#{cc[1]}"]=1
    end
  # get pronouns and make hash
    ActiveRecord::Migration.execute("select con,pronoun from cons where lng_id=#{language_id}; ").each do |j|
      con_hash_of_tenses[j[0]]= Array.new()
    end
    count = 0

    ActiveRecord::Migration.execute("select con, mood_id, tense_id, tiempo_id,verb_id,id,pronoun from cons where lng_id=#{language_id}").each do |j|
      count+=1
      temp="#{j[0]}-#{j[1]}-#{j[2]}" #conjugation-mood_id-tense_id
      con_hash_of_tenses[j[0]] << "#{j[1]}-#{j[2]}" #mood_id-tense_id #will need to run through this later before creating a new cap
      moods[temp]       = j[1]
      tenses[temp]      = j[2]
      tiempos[temp]     = j[3]
      verbs[temp]       = j[4]
      pronoun[temp]     = j[6]
      conj_id[j[0]]     = 1 # this needs to be just the clause (con), for compairing against word/word pair in cap loop
    end

  end#end suppress

  #print "#{conj_id} \n\n ***** #{con_hash_of_tenses}\n\n"
  count=0

  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Migration.execute("select cla, id, mood_id, tense_id from clas where lng_id=#{language_id};").each do |c|
      count+=1
      print "#{count} seen size: #{seen.size}\n cla_id size: #{cla_id.size}" if count%1000==2
      seen["#{c[0]}-#{c[2]}-#{c[3]}"]=1 #cla-mood_id-tense_id for clas with multiple tense parents
      cla_id["#{c[0]}-#{c[2]}-#{c[3]}"]=c[1] #word=id
    end
  end #end suppress

  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Migration.execute("select cla_id, lng_id from clas_lngs").each do |cl|
      cla_id_language_id["#{cl[0]}-#{cl[1]}"]=1000
    end
  end #end suppress


  cla_id_cap_id=Hash.new()
  count=0
  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Migration.execute("select cap,id,src_id from caps where id >= #{start} and lng_id=#{language_id}").each do |c|
      count+=1
      temp_cap_id= c[1] #id
      c[0]=c[0].gsub(/(\(|\)|"|'|\?|\!|\.|,|\n|\r|^\s+|\s+$)/," ").downcase

      #split cap into words
      words = c[0].split(/\s+/)
      #loop through each word
      words.length.times do |i|
        if i > 0 and conj_id["#{words[i-1]} #{words[i]}"] then  #"#{a[i-1]} #{a[i]}" <-- if this is a conjugation
          con_hash_of_tenses["#{words[i-1]} #{words[i]}"].each do |mood_id_tense_id|
            (mood_id,tense_id)= mood_id_tense_id.split(/-/)
            unless seen["#{words[i-1]} #{words[i]}-#{mood_id_tense_id}"] then #so here
              w2=Cla.new(:cla=>"#{words[(i-1)]} #{words[i]}",:lng_id=>language_id, :mood_id=>mood_id,:tense_id=>tense_id, :tiempo_id=>tiempos["#{words[(i-1)]}-#{mood_id_tense_id}"], :verb_id=>verbs["#{words[(i-1)]} #{words[i]}-#{mood_id_tense_id}"])
              if w2.cla and w2.cla.match(/[a-zA-Z]/) then
                w2.save!
                cla_hash[w2.cla] = w2 #save this for later when looping at end for adding to title_list
                cla_id["#{w2.cla}-#{mood_id_tense_id}"]=w2.id #need to make this key "clause"-mood_id_tense_id
              end
              seen["#{words[i-1]} #{words[i]}-#{mood_id_tense_id}"]=1
            end #end of seen
#            cla_cap["#{a[i-1]} #{a[i]}::#{temp_cap_id}"]=1    if a[i]=~/[a-zA-Z]/ #this should be ok with multiple clauses
            cla_id_cap_id["#{words[i-1]} #{words[i]}-#{mood_id_tense_id}::#{temp_cap_id}"]=1    if words[i]=~/[a-zA-Z]/ #this should be ok with multiple clauses
          end #end of loop through con_hash_of_tenses
        elsif conj_id[words[i]] and !ignore_words[words[i]] then     #This single word is a conjugation
          con_hash_of_tenses[words[i]].each do |mood_id_tense_id|
            unless seen["#{words[i]}-#{mood_id_tense_id}"] then #It is the first instance of this conjugation-mood_id-tense_id
              (mood_id,tense_id)= mood_id_tense_id.split(/-/)
              w = Cla.new(:cla=>words[i], :lng_id=>language_id, :mood_id=>mood_id,:tense_id=>tense_id, :tiempo_id=>tiempos["#{words[i]}-#{mood_id_tense_id}"], :verb_id=>verbs["#{words[i]}-#{mood_id_tense_id}"])
              if w.cla and w.cla.match(/[a-zA-Z]/) then
                w.save!
                cla_hash[w.cla] = w #save this for later when looping at end for adding to title_list
                cla_id["#{w.cla}-#{mood_id_tense_id}"]=w.id #need to make this key "clause"-mood_id_tense_id
              end
              seen["#{words[i]}-#{mood_id_tense_id}"]=1
            end #end if seen for single word
#           cla_cap["#{a[i]}-#{mood_id_tense_id}::#{temp_cap_id}"]=1  if a[i]=~/[a-zA-Z]/   #need to record cap id with clause id so can loop through cap's subs when storing languages_words
            cla_id_cap_id["#{words[i]}-#{mood_id_tense_id}::#{temp_cap_id}"]=1  if words[i]=~/[a-zA-Z]/   #need to record cap id with clause id so can loop through cap's subs when storing languages_words
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
      unless cla_id_language_id["#{cla_id[claid_capid[0]]}-#{language_id}"]  #cla_id key is clause-mood_id_tense_id
        ActiveRecord::Migration.execute("insert into clas_lngs(created_at, updated_at,cla_id,lng_id,olng_id)values('#{createdAt}', '#{createdAt}', #{cla_id[claid_capid[0]]},#{language_id},#{language_id});")
        cla_id_language_id["#{cla_id[claid_capid[0]]}-#{language_id}"]=1
      end
      #add all languages that belong to cap's name
#      print "#{claid_capid[0]} #{claid_capid[1]} <-- cap id\n";
      cap = Cap.find(claid_capid[1])

      clause= k.split(/-/)[0]
      clauses[clause] = 1
      movie_title = cap.nam.title

      #Add instance of cap_id_cla_id in cap_clas unless it already exists
      unless cap_id_cla_id["#{cap.id}-#{cla_id[claid_capid[0]]}"]
        ActiveRecord::Migration.execute("insert into caps_clas(cap_id,cla_id)values(#{cap.id},#{cla_id[claid_capid[0]]});")
        cap_id_cla_id["#{cap.id}-#{cla_id[claid_capid[0]]}"]=1
      end

      cap.nam.lngs.each do |l|
        unless cla_id_language_id["#{cla_id[claid_capid[0]]}-#{l.id}"]
          ActiveRecord::Migration.execute("insert into clas_lngs(created_at, updated_at, cla_id,lng_id,olng_id)values('#{createdAt}', '#{createdAt}', #{cla_id[claid_capid[0]]},#{l.id},#{language_id});")
          cla_id_language_id["#{cla_id[claid_capid[0]]}-#{l.id}"]=1
        end
      end
    end #end of looping through word_cap
  end #end suppress

  clauses.each do |k,v|
    print "last: #{k}\n"
    cla_hash[k].save
  end
end

#Goes through vocab table, searching words and noting caption languages it's been translated to
#Also saves cap media tags in tags_vocs
task :chinese_idioms =>[:environment] do
  lng_id = Lng.where(cod: 'chi_hans').first.id
  Entry.where(is_idiom: true).all.each do |idiom|
    second = idiom.entry.split("，")[1]
    caps = Cap.search "\"#{idiom.entry}\"", :match_mode=>:extended, :with=>{:lng_id=>lng_id},:per_page=>3000
    if caps.length > 0 then
      caps.each do | cap |
        puts cap.nam.nam
        EntriesNam.find_or_create_by(
          entry_id: idiom.id,
          nam_id: cap.nam.id,
        )
      end
    end
  end
end


#Goes through vocab table, searching words and noting caption languages it's been translated to
#Also saves cap media tags in tags_vocs
task :count_chinese =>[:environment] do
  c                     = 0
  lng_id                = Lng.where(cod: 'chi_hans').first.id
  lv                    = Hash.new() #lngs vocs
  nv                    = Hash.new() #nams_vocs #Not sure how to handle caps_vocs with chinese frequency lists
  cv                    = Hash.new() # caps_vocs
  lngs_for_name         = Hash.new()

  # Create hash of LangaugesVocab so later you know whether to update or insert new record.
  print "creating languages vocabs hash\n"
  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Migration.execute("select lng_id, voc_id, seen from lngs_vocs where olng_id=#{lng_id}").each do |l|
      lv["#{l[0]}-#{l[1]}"]=l[2]
    end
  end

  # Create hash nams vocs so later you know whether to update or insert new record.
  ActiveRecord::Migration.execute("select nam_id,voc_id from nams_vocs").each do |n|
    nv["#{n[0]}-#{n[1]}"]=1
  end

  # Create hash nams vocs so later you know whether to update or insert new record.
  ActiveRecord::Migration.execute("select cap_id,voc_id from caps_vocs").each do |c|
    cv["#{c[0]}-#{c[1]}"]=1
  end

  #Create hash names, values being arays of their languages
  print "creating names hash\n"
  Nam.where(lng_id: lng_id).each do |n|
    if n.lngs.size>0
      lngs_for_name[n.id] = Array.new()
      n.lngs.each do |l|
        lngs_for_name[n.id] << l.id
      end

      lngs_for_name[n.id]<<lng_id
      lngs_for_name[n.id].uniq!
    end
  end #end of name find loop
  print "about to loop through caps\n"

  count = Voc.where(lng_id: lng_id).count

  print "total_vocabs for #{lng_id} is #{count}\n"

  #loop through each vocab, create language_count hash for each, then insert or update
  ActiveRecord::Migration.suppress_messages do
    #ActiveRecord::Migration.execute("select id,voc from vocs where lng_id=#{lng_id} and voc is not null and CHARACTER_LENGTH(voc) >1 and id > 160000 and voc not like \"%�%\" and level is null order by id").each do |voc|
    ActiveRecord::Migration.execute("select id, voc from vocs where lng_id=#{lng_id} and voc is not null and voc not like \"%�%\" order by id").each do |voc|
      begin
      c+=1
      print "#{c} #{voc[0]}  #{voc[1]} ***\n" if c%200==2
      language_count  = Hash.new()

      caps            = Cap.search "\"#{voc[1]}\"", :match_mode=>:extended, :with=>{:lng_id=>lng_id},:per_page=>3000
      #caps            = Cap.where("cap like '%#{voc[1]}%' and lng_id = #{lng_id}")
      #puts "#{voc} - #{caps.length} cccc"
      caps.each do |cap|
        #update caps_vocs
        unless nv["#{cap.nam_id}-#{voc[0]}"]
          ActiveRecord::Migration.execute("insert into nams_vocs(nam_id,voc_id)values(#{cap.nam_id},#{voc[0]})")
          nv["#{cap.nam_id}-#{voc[0]}"] =1
        end

        unless cv["#{cap.id}-#{voc[0]}"]
          # Not sure why limiting to bigrams
          if voc[1].length > 1
            ActiveRecord::Migration.execute("insert into caps_vocs(cap_id,voc_id)values(#{cap.id},#{voc[0]})")
          end
          cv["#{cap.id}-#{voc[0]}"] =1
        end

        if lngs_for_name[cap.nam_id]
          #add all nam names to each word
          lngs_for_name[cap.nam_id].each do |lang_id|
            if language_count["#{lang_id}-#{voc[0]}"] then
              language_count["#{lang_id}-#{voc[0]}"]+=1
            else
              language_count["#{lang_id}-#{voc[0]}"]=1
            end
          end #end loop through each e in name_id array
        end #end if name_id array exists
      end #end cap loop

      language_count.each do |k,v|
        (lang_id,vocab_id)=k.split(/-/)

        if lv[k]
          ActiveRecord::Migration.execute("update lngs_vocs set seen=#{v} where lng_id=#{lang_id} and voc_id=#{vocab_id};") if v!=lv[k]
        else
          ActiveRecord::Migration.execute("insert into lngs_vocs(lng_id,voc_id,seen,olng_id)values(#{lang_id},#{vocab_id},#{v},#{lng_id})")
        end
      end
    rescue
      print "nearly got messed up with #{voc[0]} #{voc[1]}\n"
    end
    end #end vocab loop
   # ActiveRecord::Migration.execute("update last_cap_id set cap_id=#{last_cap_id} where des = 'vocabs';")
  end #end suppression
 #Rails.cache.clear()
end
