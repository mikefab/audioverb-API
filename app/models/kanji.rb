class Kanji < ApplicationRecord
  has_many :entries
  #attr_accessible :kanji, :pinyin

  def self.return_kanji(grams)
    gram_pinyin = Hash.new
    grams.each{|k, v| gram_pinyin[k] = KANJI_PINYIN[k]}
    return gram_pinyin
  end

  # bigram clicked. Return Entries with bigram, but not if it is *the* bigram
  def self.multi(phrase, media)
    entries = []
    Entry.where("entry like \"%#{phrase}%\" and entry != \"#{phrase}\"").order(:id).reverse.each do |e|
      puts e.pinyin
      if media.match(/all/) # Get all entries that match phrase
        if Cap.search("\"#{e.entry}\"").count > 0
          entries.push({id: e.id, entry: e.entry, pinyin: e.pinyin})
        end
      else # Nam specific entry search
        n = Nam.where(nam: media.gsub(/_/, ' ')).first
        if n.caps.search("\"#{e.entry}\"").count > 0
          entries.push({id: e.id, entry: e.entry, pinyin: e.pinyin})
        end
      end
    end



    entries.unshift({entry: phrase})
    [{kanji: phrase, clean_entries: entries }]
  end

  def clean_entries
    Entry.get_clean_entries(self.id)
  end

  def as_json(options={})
    super(:include => [:clean_entries => { :include => :defs }])
  end
end
