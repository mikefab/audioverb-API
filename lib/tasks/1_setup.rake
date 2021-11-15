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
  basedir = Rails.root.to_s + "/lib/text_files/verbs"
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
