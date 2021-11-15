
#rake create_english_clauses start=822936 --trace
#this creates an index of clauses that match conjugations in verbs table
task :create_english_clauses => [:environment] do
  start = ENV['start'] || 0 #for starting in the middle of caps
  stop = ENV['stop'] || Cap.last.id #for starting in the middle of caps
  cla_hash = Hash.new()
  # tag_hash = Hash.new()

  print "make hash of clause objects\n"
  Cla.where(lng_id: 122).each do |c|
    cla_hash[c.id] = c #cla.id => Cla
  end


  # user=User.first
  $english_id  = Lng.where(cod: 'eng').first.id
  id_tiempo   = Hash.new
  con_id      = Hash.new()
  tiempos     = Hash.new()
  $tense_id    = Hash.new()
  $mood_id     = Hash.new()
  $verbs       = Hash.new()
  cla_id_lng_id = Hash.new()
  cap_id_cla_id = Hash.new() #get all cap-cla ids from caps_clas
  cla_id        = Hash.new()

  print "Make hash of clas to ids\n"
  Cla.where(lng_id: $english_id).each do |c|
    cla_id["#{c.cla}"]=c.id
  end

  #Make hash of cap_id_cla_id so you know what you have already
  ActiveRecord::Migration.execute("select cap_id,cla_id from caps_clas").each do |cc|
    cap_id_cla_id["#{cc[0]}-#{cc[1]}"]=1
  end

  # print "clas: #{cla_id.size} cla_lng count: #{cla_id_lng_id.size}\n"
  Tiempo.where(lng_id: $english_id).each do |t|
    id_tiempo[t.id]=t.tiempo
  end

  print "tenses hash\n"
  Tense.where(lng_id: $english_id).each do |t|
    $tense_id[t.mood_id.to_s + '^' + t.tense]=t.id
  end

  Mood.where(lng_id: $english_id).each do |m|
    $mood_id[m.mood]=m.id
  end


  puts $mood_id
  print "starting conjugation hashes\n";
  cons=ActiveRecord::Migration.execute("select con,id,tiempo_id,verb_id from cons where lng_id=#{$english_id};")
  #conjugations=Conjugation.find_by_sql("select conjugation,tiempo_id,verb_id,id from conjugations where language_id=#{language_id};")
  cons.each do |c|
    con           = c[0]  #conjugation
    con_id[con]   = c[1]  #id
    tiempos[con]  = c[2]  #tiempo_id
    $verbs[con]   = c[3]  #verb_id
  end

  print "finished conjugation hashes\n"
  start=start.to_i
  stop=stop.to_i
  print "Starting with #{start} and Ending with #{stop}\n"
  count=0
  print "Start: #{start}\n"
  print "done with conj hash, getting caps\n"
  print "about to start from #{start}\n"
  print "#{start} #{stop} starstaop\n"
  def update_lookups(mood, tense)
    if !$mood_id[mood] then
      m = Mood.find_or_create_by(mood: mood, lng_id: $english_id)
      $mood_id[mood] = m.id
    end
    if !$tense_id[mood + '-' + tense] then
      t = Tense.find_or_create_by(mood_id: $mood_id[mood], tense: tense, lng_id: $english_id)
      $tense_id[$mood_id[mood].to_s + '^' + tense] = t.id
    end
  end

  def scan_regex(list, regex, mood, tense, con, verb)
    update_lookups(mood, tense)
    if match = con.match(/#{regex}/i)
      temp = "#{con}"
      con = con.gsub(/#{regex}/i,"::")
      # tense_id : cla : verb_id

      list[$mood_id[mood].to_s + ":" + $tense_id[$mood_id[mood].to_s + '^' + tense].to_s + ":" + match.to_s+":"+ verb.to_s]=1
    end
    return list
  end

  ActiveRecord::Migration.execute("select cap,id from caps where id >= #{start}  and id <= #{stop} and lng_id=#{$english_id}").each do |c|
    puts "#{c[0]}"
    count=count+1
    # print "id: #{c[1]} | c: #{count}.\n" if count%500==2
    if count%500==2 then
      Last.create(:num=>c[1],:kind=>"cap")
    end

    c[0].downcase!
    list = Hash.new()
    cla = Hash.new()
    a = Array.new
    a = c[0].split(/\s+/)

    for i in a.length.downto 0 do
      if con_id[a[i]] then  #if word matches a conjugation
        #print "#{a[i]} #{con_id[a[i]]} #{id_tiempo[tiempos[a[i]]]}\n"
        if (id_tiempo[tiempos[a[i]]].match(/infinitive/)) then
          #Subjunctive->future: if I were to arise
          regex=/(i|you|he|she|it|they|we)\s+were\s+(not\s+)*to\s+(not\s+)*#{a[i]}/
          list = scan_regex(list, regex, 'subjunctive', 'future', c[0], $verbs[a[i]])

          #Subjunctive->present: if I should arise
          regex=/(i|you|he|she|it|they|we)\s+should\s+(not\s+)*#{a[i]}/
          list = scan_regex(list, regex, 'subjunctive', 'present', c[0], $verbs[a[i]])
        end

        #Conditional perfect continuous: I would have been playing
        if (id_tiempo[tiempos[a[i]]].match(/gerund/i)) then
          regex= /would\s+(not\s+)*have\s+(not\s+)*been\s+#{a[i]}/
          list = scan_regex(list, regex, 'conditional', 'perfect continuous', c[0], $verbs[a[i]])

          #compound continuous -> present perfect: I have been playing I have been playing
          regex= /\bhave\s+(not\s+)*been\s+#{a[i]}/
          list = scan_regex(list, regex, 'conditional', 'present perfect', c[0], $verbs[a[i]])

          # conditional -> present continuous: I would be playing
          regex= /\bwould\s+(not\s+)*be\s+#{a[i]}/
          list = scan_regex(list, regex, 'conditional', 'present continuous', c[0], $verbs[a[i]])

          # conditional -> present continuous: I'd be playing
          regex= /\b[a-z]{1,4}'d\s+be\s+#{a[i]}/ #Conditional Progressive: I'd be playing

          list = scan_regex(list, regex, 'conditional', 'present continuous', c[0], $verbs[a[i]])

          #  compound continuous -> future: I will be playing: I will be playing
          regex= /\bwill\s+(not\s+)*be\s+#{a[i]}/
          list = scan_regex(list, regex, 'compound continuous', 'future', c[0], $verbs[a[i]])

          # compound continuous -> future:: I'll be playing
          regex= /\b[a-z]{1,4}'ll\s+(not\s+)*be\s+#{a[i]}/
          list = scan_regex(list, regex, 'compound continuous', 'future', c[0], $verbs[a[i]])
          #Continuous -> past continuous: I was playing
          regex= /\bwas\s+(not\s+)*#{a[i]}/
          list = scan_regex(list, regex, 'continuous', 'past continuous', c[0], $verbs[a[i]])
         # Continuous -> past continuous: I wasn't playing
          regex= /\bwasn't\s+#{a[i]}/
          list = scan_regex(list, regex, 'continuous', 'past continuous', c[0], $verbs[a[i]])
          #continuous -> past continuous: you/they were playing
          regex= /\bwere\s+(not\s+)*#{a[i]}/
          list = scan_regex(list, regex, 'continuous', 'past continuous', c[0], $verbs[a[i]])
          #continuous -> past continuous: you/they weren't playing
          regex= /\bweren't\s+#{a[i]}/
          list = scan_regex(list, regex, 'continuous', 'past continuous', c[0], $verbs[a[i]])
          # compound continuous -> present perfect:  I have been playing
          regex= /\bhave\s+(not\s+)*((j|already)\s+)*been\s+#{a[i]}/
          list = scan_regex(list, regex, 'compound continuous', 'present perfect', c[0], $verbs[a[i]])
         # compound continuous -> present perfect:  I haven't been playing
          regex= /\bhaven't\s+((just|already)\s+)*been\s+#{a[i]}/
          list = scan_regex(list, regex, 'compound continuous', 'present perfect', c[0], $verbs[a[i]])
         # compound continuous -> present perfect::  he has been playing
          regex= /\bhas\s+(not\s+)*((just|already)\s+)*been\s+#{a[i]}/
          list = scan_regex(list, regex, 'compound continuous', 'present perfect', c[0], $verbs[a[i]])
         # compound continuous -> present perfect::  hasn't been playing
          regex= /\bhasn't\s+((just|already)\s+)*been\s+#{a[i]}/
          list = scan_regex(list, regex, 'compound continuous', 'present perfect', c[0], $verbs[a[i]])
          # compound continuous -> present perfect:  I've not been playing
          regex= /\b[a-z]{1,4}'ve\s+(not\s+)*(just\s+)*been\s+#{a[i]}/
          list = scan_regex(list, regex, 'compound continuous', 'present perfect', c[0], $verbs[a[i]])
          #compound continuous -> present perfect::  had not been playing
          regex= /\bhad\s+(not\s+)*(just\s+)*been\s+#{a[i]}/
          list = scan_regex(list, regex, 'compound continuous', 'present perfect', c[0], $verbs[a[i]])
          #compound continuous -> present perfect:  I'd not been playing
          regex= /\b[a-z]{1,4}'d\s+(not\s+)*(just\s+)*been\s+#{a[i]}/
          list = scan_regex(list, regex, 'compound continuous', 'present perfect', c[0], $verbs[a[i]])
        end


        if (id_tiempo[tiempos[a[i]]].match(/(past|participle)/)) then
          # conditional -> present: I would not play I would not play
          regex= /\bwould\s+(not\s+)*have\s+(not\s+)*#{a[i]}/
          mood = 'conditional'
          tense = 'present'
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])
         #Conditional Perfect: I'd not play
          regex= /\b[a-z]{1,4}'d\s(not\s+)*have\s+(not\s+)*#{a[i]}/
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])

          # perfect -> future Perfect:
          regex=/\bwill\s+have\s+#{a[i]}/
          mood = 'perfect'
          tense = 'future perfect'
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])
         # perfect -> future Perfect:
          regex=/\b[a-z]{1,4}'ll\s+have\s+#{a[i]}/
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])
        end


        if (id_tiempo[tiempos[a[i]]].match(/infinitive/)) then
          # conditional -> present: I would play
          regex= /\bwould(\s+not)*\s+#{a[i]}/
          mood = 'conditional'
          tense = 'present'
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])
          # conditional -> present: I'd would play
          regex= /\b[a-z]{1,4}'d(\s+not)*\s+#{a[i]}/
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])
          # indicative -> future: I will arise
          regex= /\bwill(\s+not)*\s+#{a[i]}/
          mood = 'indicative'
          tense = 'future'
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])
          # indicative -> future I'll arise
          regex= /\b[a-z]{1,4}'ll\s+#{a[i]}/
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])
          # going-to -> future: I am going to cry
          regex= /\bam\s+(not\s+)*going\s+to\s+#{a[i]}/
          mood = 'going-to'
          tense = 'future'
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])
          # going-to -> future: I am going to cry
          regex= /\bare\s+(not\s+)*going\s+to\s+#{a[i]}/
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])
          # going-to -> future: I am not going to cry
          regex= /\b(i'm|\b[a-z]{1,4}'re|\b[a-z]{1,4}'s)\s(not\s+)*+going\s+to\s+#{a[i]}/
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])
        end

        if (id_tiempo[tiempos[a[i]]].match(/gerund/)) then
          # continuous -> present continuous: I am arising
          regex= /\b+am\s+(not\s+)*#{a[i]}/
          mood = 'continuous'
          tense = 'present continuous'
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])
          # continuous -> present continuous: it is arising
          regex= /\bis\s+(not\s+)*#{a[i]}/
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])
          #continuous -> present continuous: I'm rising
          regex= /\b(i'm|\b[a-z]{1,4}'re|\b[a-z]{1,4}'s)\s+(not\s+)*((just|already)\s+)*#{a[i]}/
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])
        end

        if (id_tiempo[tiempos[a[i]]].match(/(participle)/)) then
          mood = 'perfect'
          tense = 'present perfect'
          # perfect ->  present perfect: I have arisen
          regex= /\bhave\s+(not\s+)*((just|already)\s+)*#{a[i]}/
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])
          # perfect ->  present perfect: I have arisen
          regex= /\bhave\s+((i|you|he|she|it|they|we)\s+)*(not\s+)*((just|already)\s+)*#{a[i]}/
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])
        end

        if (id_tiempo[tiempos[a[i]]].match(/(past|participle)/)) then
          mood = 'perfect'
          tense = 'present perfect'
          # perfect -> present perfect: I've arisen
          regex= /\b[a-z]{1,4}'ve\s+(not\s+)*((just|already)\s+)*#{a[i]}/
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])
          # perfect -> present perfect: it has played
          regex= /\bhas\s+(not\s+)*((just|already)\s+)*#{a[i]}/
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])

          # perfect -> present perfect: it's played
          regex= /\b(it's|he's|she's)\s+(just\s+)*#{a[i]}/
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])

          # perfect -> past perfect: I had played
          regex= /\bhad\s+(not\s+)*(just\s+)*#{a[i]}/
          mood = 'perfect'
          tense = 'past perfect'
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])
          # perfect -> past perfect: I'd played
          regex= /\b[a-z]{1,4}'d\s+(not\s+)*(just\s+)*#{a[i]}/
          mood = 'perfect'
          tense = 'past perfect'
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])
        end


        # if (id_tiempo[tiempos[a[i]]].match(/infinitive/)) then
        #   #Subjunctive->present: that we arrive
        #   regex= /\bthat\s+(i|you|he|she|they|we)\s+(not\s+)*#{a[i]}/
        #   if match = c[0].match(/#{regex}/i)
        #     c[0] = c[0].gsub(/#{regex}/i,"::")
        #
        #     #$list <<   $tense_id["subjunctive present"].to_s+":" + match.to_s+":"+$verbs[a[i]].to_s
        #        $list[$tense_id["subjunctive present"].to_s+":" + match.to_s+":"+$verbs[a[i]].to_s]=1
        #   end
        # end
        #
        #
        # if (id_tiempo[tiempos[a[i]]].match(/(past|participle)/i)) then
        #   #Subjunctive->past: if I arose
        #   regex=/\bif\s+(i|you|he|she|it|they|we)\s+#{a[i]}/
        #  if match = c[0].match(/#{regex}/)
        #     c[0] = c[0].gsub(/#{regex}/i,"::")
        #
        #     #$list <<   $tense_id["subjunctive past"].to_s+":" + match.to_s+":"+$verbs[a[i]].to_s
        #        $list[$tense_id["subjunctive past"].to_s+":" + match.to_s+":"+$verbs[a[i]].to_s]=1
        #  end
        # end

        if (id_tiempo[tiempos[a[i]]].match(/past/i)) then
            #indicative -> simple past: It happened, you chose
          regex= /\b(i|you|he|she|it|they)\s+#{a[i]}/
          list = scan_regex(list, regex, 'indicative', 'simple past', c[0], $verbs[a[i]])
        end

        if (id_tiempo[tiempos[a[i]]].match(/infinitive/)) then
          # indicative -> present: play
          regex= /\b(I|you|they|we|to)\s+#{a[i]}\b/
          mood = 'indicative'
          tense = 'present'
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])
          # indicative -> present: he plays
          regex= /\b(he|she|it)\s+#{a[i]}s\b/
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])
          #           #adapts it
          # regex= /\b#{a[i]}s?\s+(it|them|him|her|me|you|us)\b/
          # if match = c[0].match(/#{regex}/i)
          #   c[0] = c[0].gsub(/#{regex}/i,"::")
          #   $list[$tense_id["simple present"].to_s+":" + match.to_s+":"+$verbs[a[i]].to_s]=1
          # end

        #             #adapt it
        #   regex= /\b#{a[i]}\s+(it|them|him|her|me|you|us)\b/
        #   if match = c[0].match(/#{regex}/i)
        #     c[0] = c[0].gsub(/#{regex}/i,"::")
        #     $list[$tense_id["simple present"].to_s+":" + match.to_s+":"+$verbs[a[i]].to_s]=1
        #   end
        end

        # continuous ->  present continuous: playing
        if (id_tiempo[tiempos[a[i]]].match(/gerund/i)) then
          mood = 'continuous'
          tense = 'present continuous'
          regex= /^#{a[i]}\b/
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])
          regex= /\b#{a[i]}\b/
          list = scan_regex(list, regex, mood, tense, c[0], $verbs[a[i]])
        end

        # if (id_tiempo[tiempos[a[i]]].match(/participle/i)) then
        #   #present->perfect: arisen
        #   regex=/^#{a[i]}\b/
        #  if match = c[0].match(/#{regex}/)
        #     c[0] = c[0].gsub(/#{regex}/i,"::")
        #     $list[$tense_id["present perfect"].to_s+":" + match.to_s+":"+$verbs[a[i]].to_s]=1
        #  end
        # end
        #
        # #simple past
        # if (id_tiempo[tiempos[a[i]]].match(/past/i)) then
        #   #simple->past: arose
        #   regex=/^#{a[i]}\b/
        #  if match = c[0].match(/#{regex}/)
        #     c[0] = c[0].gsub(/#{regex}/i,"::")
        #     $list[$tense_id["simple past"].to_s+":" + match.to_s+":"+$verbs[a[i]].to_s]=1
        #  end
        # end
      end #end if is conjugation
    end #end of looping through each word
    #puts $list if $list.length > 0
    #puts $tense_id

    ActiveRecord::Migration.suppress_messages do
      list.each do |k,v|
        set = k.split(":")
        mood_id = set[0]
        tense_id = set[1]
        cla = set[2]
        verb_id = set[3]

        #Create new cla if cla not seen yet.
        unless cla_id[cla] then
          puts cla
          cla=Cla.new(cla: cla,lng_id: $english_id, tense_id: tense_id, verb_id: verb_id, mood_id: mood_id)
          cla.save
          cla_hash[cla.id]=cla
          cla_id[cla]=cla.id
        end
        #
        #Add instance of cap_id_cla_id in cap_clas unless it already exists
        unless cap_id_cla_id["#{c[1]}-#{cla_id[cla]}"]
          ActiveRecord::Migration.execute("insert into caps_clas(cap_id,cla_id)values(#{c[1]},#{cla_id[cla]});")
          cap_id_cla_id["#{c[1]}-#{cla_id[cla]}"]=1
        end
        #
        #Add instance of cla_id_lng_id in cla_lngs for ENGLISH unless it already exists
        unless cla_id_lng_id["#{cla_id[cla]}-#{$english_id}"]
          ActiveRecord::Migration.execute("insert into clas_lngs(cla_id,lng_id,olng_id)values(#{cla_id[cla]},#{$english_id},#{$english_id});")
          cla_id_lng_id["#{cla_id[cla]}-#{$english_id}"]=1
        end
        #
        # #total_caps += Time.now - past_caps
        #
        #
        # #past_lookup = Time.now
        # cap=Cap.find(c[1]) #this might seem redundant. But, in the start of looping thru caps is by activerecord migration. Doing Cap.all do takes too long to prepare.
        #
        #
        # cap.nam.lngs.each do |l|
        #   unless cla_id_lng_id["#{cla_id[pair[1]]}-#{l.id}"]
        #     ActiveRecord::Migration.execute("insert into clas_lngs(cla_id,lng_id,olng_id)values(#{cla_id[pair[1]]},#{l.id},#{$english_id});")
        #     cla_id_lng_id["#{cla_id[pair[1]]}-#{l.id}"]=1
        #   end
        # end
        #total_lang=Time.now-past_lang
      end #end $list
    end #end suppress
  #    gap = ((Time.now-past)*789029)/60
#    print "#{gap}\n"

  end#end of looping through each cap
  puts $tense_id
  print "done with $list\n"
end
