class Entry < ApplicationRecord
  belongs_to :kanji
  has_many :defs
  #attr_accessible :entry, :kanji_id, :pinyin

  def self.get_clean_entries(kanji_id)
    entries = Array.new
    Entry.where(kanji_id: kanji_id).each do |entry|
      entries << entry if Cap.search("\"#{entry.entry}\"").count > 0
    end
    entries
  end

  def as_json(options={})
    super(:include =>[:defs])
  end

  #entries.each{|e| defs[e.id] = e.defs.map(&:def).uniq}

end
