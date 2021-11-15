#RAILS_ENV=production scan_idioms kind=v --trace
task :scan_idioms=>[:environment] do
  english_id=Lng.find_by_cod('eng').id
  hash=Hash.new()  #"check"=>"(checks|check|checking|checked|checked)"
  print "make array of verbs that are first words in idioms\n"
  idiom_verbs=Hash.new()
  idos = Ido.all #.where(kind: 'e')
  idos.each do |i| #kind is p or v
    a_idiom = i.ido.split(/\s+/) #break idiom into array based on spaces
    idiom_verbs[a_idiom[0]]=1    #first word
  end
  count=0
  print "put only verbs used in front of idioms in memory with their conjugations. Trying to save ram\n"
  Verb.where(lng_id: english_id).each do |v|
    if idiom_verbs[v.verb] then
      if v.verb.match(/(o$|h$)/i) then
        hash[v.verb]="(#{v.verb}es|" if v.verb!="be"
      elsif v.verb=="be" then
        hash[v.verb]="("
      else
        hash[v.verb]="(#{v.verb}s|"
      end
      v.cons.each do |c|
        hash[v.verb] = hash[v.verb] + "#{c.con}|" if c.lng_id==english_id
      end
      hash[v.verb] = hash[v.verb] + "am|are|is|'s|'m|'re" if v.verb=="be"
      hash[v.verb] = hash[v.verb]+")"
      hash[v.verb].gsub!(/\|\)/,")")
      #puts hash[v.verb]
    end
  end
  puts hash
  c=0
  idos.each do |i|
    if i.ido.match(/be it/) then
      next
    end
    idiom = "#{i.ido.downcase}"
    language_count=Hash.new()
    c+=1

    a_idiom = i.ido.downcase.split(/\s+/)
    puts "#{a_idiom[0]} - #{hash[a_idiom[0]]} -  #{idiom}"
    idiom.gsub!(/#{a_idiom[0]}/,"#{hash[a_idiom[0]]}") if hash[a_idiom[0]]

    idiom.gsub!(/someone/,"(me|him|her|them|you|them|someone)")
    idiom.gsub!(/oneself/,"(myself|yourself|hisself|himself|herself|theirselves|ourselves|yourselves)")
    if idiom.match(/one's/) then
        idiom.gsub!(/one's/,"(my|his|her|their|your|our|one's|someone's)")
    elsif idiom.match(/someone's/) then
      idiom.gsub!(/someone's/,"(my|his|her|their|your|our|one's|someone's)")
    end


    #puts "#{idiom}-"
    sphinx_idiom = ''
    if i.kind.match('e') then
      #if (idiom.match(/(.+\s*?)(-)(\s+(a|the)$)/i)) then
      if (idiom.match(/(.+?)(\s*-\s*)(a|the)$/i)) then
        sphinx_idiom = "#{$3} #{$1}"
      #  puts sphinx_idiom
      else
        sphinx_idiom = idiom
      end

    else
      sphinx_idiom = idiom.gsub(/\s+/," << ")#.sub(/\s*<<\s*$/, '').sub(/<<\s*-\s*<</, '-')
    end
    sphinx_idiom.gsub!('!', '')
    i.pattern = sphinx_idiom
    i.save!
    count=count+1
    caps = Cap.search("#{sphinx_idiom}", :with=>{:lng_id=>english_id},:per_page=>1000)
    #puts sphinx_idiom
#
#
#Cap.search("(aims|aim|aiming|aimed|aimed) NEAR/1 << high", :with=>{:lng_id=>english_id},:per_page=>1000)

    caps.each do |cap|
      if (cap.cap.match(/#{idiom}/)) then
          puts "#{i.ido} | #{sphinx_idiom} | #{idiom} | #{cap.cap}"
          IdosNam.find_or_create_by(
            ido_id: i.id,
            nam_id: cap.nam.id,
          )
      end
    end #end of caps loop
   end #end of idiom loop
#   Rails.cache.clear()
end



#Goes through vocab table, searching words and noting caption languages it's been translated to
#Also saves cap media tags in tags_vocs
task :chinese_idioms =>[:environment] do
  lng_id = Lng.where(cod: 'chi_hans').first.id
  # Entry.where(is_idiom: true).all.each do |idiom|
  Entry.where("length(entry) > 8").all.each do |idiom|
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
task :scan_clas =>[:environment] do
  lng_id = Lng.where(cod: ENV['language']).first.id
  cla_hash = Hash.new()
  cap_cla_id = Hash.new()  # get all cap-cla ids from caps_clas
  # Get existing clas per lng
  Cla.where(:lng_id=>lng_id).each do |c|
    cla_hash[c.cla] = c.id
  end

  CapsCla.all.each do |cc|
    cap_cla_id["#{cc.cap_id}^#{cc.cla_id}"]=1
  end

  # Entry.where(is_idiom: true).all.each do |idiom|
  count=0
  Con.where(lng_id: lng_id).all.each do |con|
    count+=1
    puts count if count%1000 == 0
    #second = idiom.entry.split("，")[1]
    caps = Cap.search "\"#{con.con}\"", :match_mode=>:extended, :with=>{:lng_id=>lng_id},:per_page=>3000
    if caps.length > 0 then

      unless cla_hash[con.con] then
        cla = Cla.find_or_create_by(
              cla: con.con,
              lng_id: lng_id,
              mood_id: con.mood_id,
              tense_id: con.tense_id,
              verb_id: con.verb_id
            )
        cla_hash[con.con] = cla.id
      end

      caps.each do | cap |
        unless cap_cla_id["#{cap.id}^#{cla_hash[con.con]}"] then
          CapsCla.new(
            cla_id: cla_hash[con.con],
            cap_id: cap.id
          ).save!
        end
      end
    end
  end
end


#Goes through vocab table, searching words and noting caption languages it's been translated to
#Also saves cap media tags in tags_vocs
task :scan_prepositions =>[:environment] do
  lng_id = Lng.where(cod: ENV['language']).first.id
  # Entry.where(is_idiom: true).all.each do |idiom|
  Prep.where(lng_id: lng_id).all.each do |prep|
    puts "#{prep.prep} #{lng_id}!!!"
    #second = idiom.entry.split("，")[1]
    caps = Cap.search "\"#{prep.prep}\"", :match_mode=>:extended, :with=>{:lng_id=>lng_id},:per_page=>3000
    if caps.length > 0 then
      caps.each do | cap |
        puts cap.nam.nam
        NamsPrep.find_or_create_by(
          prep_id: prep.id,
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
      lv["#{l[0]}^#{l[1]}"]=l[2]
    end
  end

  # Create hash nams vocs so later you know whether to update or insert new record.
  ActiveRecord::Migration.execute("select nam_id,voc_id from nams_vocs").each do |n|
    nv["#{n[0]}^#{n[1]}"]=1
  end

  # Create hash nams vocs so later you know whether to update or insert new record.
  ActiveRecord::Migration.execute("select cap_id,voc_id from caps_vocs").each do |c|
    cv["#{c[0]}^#{c[1]}"]=1
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
        unless nv["#{cap.nam_id}^#{voc[0]}"]
          ActiveRecord::Migration.execute("insert into nams_vocs(nam_id,voc_id)values(#{cap.nam_id},#{voc[0]})")
          nv["#{cap.nam_id}^#{voc[0]}"] =1
        end

        unless cv["#{cap.id}^#{voc[0]}"]
          # Not sure why limiting to bigrams
          if voc[1].length > 1
            ActiveRecord::Migration.execute("insert into caps_vocs(cap_id,voc_id)values(#{cap.id},#{voc[0]})")
          end
          cv["#{cap.id}^#{voc[0]}"] =1
        end

        if lngs_for_name[cap.nam_id]
          #add all nam names to each word
          lngs_for_name[cap.nam_id].each do |lang_id|
            if language_count["#{lang_id}^#{voc[0]}"] then
              language_count["#{lang_id}^#{voc[0]}"]+=1
            else
              language_count["#{lang_id}^#{voc[0]}"]=1
            end
          end #end loop through each e in name_id array
        end #end if name_id array exists
      end #end cap loop

      language_count.each do |k,v|
        (lang_id,vocab_id)=k.split(/\^/)

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
