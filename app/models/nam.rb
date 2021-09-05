class Nam < ApplicationRecord
  has_and_belongs_to_many :lngs, :join_table => "lngs_nams"
  has_many :caps
  has_and_belongs_to_many :vocs, :join_table => "nams_vocs"
  has_and_belongs_to_many :entries, :join_table => "entries_nams"

  def self.decode(nam)
    # params[:nam] could be some_tv_show_4_3x
    if my_match = /(.+)_(\d+_\d+x\d+)/.match(nam)
      return "#{my_match[1].gsub(/_/, '.')}.#{my_match[2]}"
    end
    return nam.gsub(/_/, ' ')
  end

  def self.playlist(cap_id)
    cap          = Cap.find(cap_id)
    first_cap_id = Cap.where(nam_id: cap.nam_id).order(:num).first.id
    last_cap_id  = Cap.where(nam_id: cap.nam_id).order(:num).last.id

    first =  cap.id      - first_cap_id < 6 ? first_cap_id : cap.id - 5
    last  =  last_cap_id - cap.id       < 6 ? last_cap_id  : cap.id + 5
    Cap.where("id >= #{first} and id <= #{last}").order(:num)
  end


  def self.sub_playlist(sub_id)
    sub          = Sub.find(sub_id)

    first_sub_id = Sub.where(nam_id: sub.nam_id, lng_id: 122).order(:num).first.id
    last_sub_id  = Sub.where(nam_id: sub.nam_id, lng_id: 122).order(:num).last.id

    first =  sub.id      - first_sub_id < 6 ? first_sub_id : sub.id - 5
    last  =  last_sub_id - sub.id       < 6 ? last_sub_id  : sub.id + 5
    Sub.where("id >= #{first} and id <= #{last}").order(:num)
  end

  # For cumulative vocab level
  def level
    c = 0
    self.vocs.each{|nv|  c+= nv.level if nv.level}
    c
  end

  def slug
    self.nam.gsub(/\s+/, '_')
  end

  def last_cap_stop
    self.caps.last
  end

  def get_caps_by_search(search)
    #self.caps.search(search, :match_mode=>:phrase, :per_page=>3)
    #self.caps.search('"'+ search + '"', :per_page => 25, :match_mode => :extended)
    self.caps.search('"'+ search + '"', :per_page => 25)
  end

  def self.to_flare_single(nam, term)
    nam = Nam.find_by_nam(nam)
    h = {name: 'flare', size: 1000, children: []}
    caps = nam.get_caps_by_search(term).map { |i| {
        nam: i.nam.nam.gsub(/\s+/, '.'),
        num: i.num,
        start: i.start,
        stop: i.stop,
        name: i.nam,id: i.id,
        cap: i.cap,
        size: (i.cap.length * 1000)
      }
    }

    h[:children].push({name: nam.nam, size: (caps.length * 100) , children: caps}) if caps.length  > 0

    # dramas.keys.each{|k| h[:children].push dramas[k]}
    h
  end
  def self.to_flare(term, lng_id)
    # if media == 'all'
    #   nams = Nam.search(term)
    # else
    #   # nams = Nam.where(nam: media.gsub(/_/, ' '))
    #   nams = Nam.where(lng_id: 931)
    # end
    nams = Nam.where(lng_id: lng_id)
    h = {name: 'flare', size: 1000, children: []}
    dramas = {}
    nams.each do |n|
      caps = n.get_caps_by_search(term).map{ |i| {
        nam: i.nam.nam.gsub(/\s+/, '.'),
        num: i.num,
        start: i.start,
        stop: i.stop,
        name: i.nam,id: i.id,
        cap: i.cap,
        size: (i.cap.length * 1000)
      }
    }
      # if my_match = /(.+)\.(\d+_\d+x\d+)/.match(n.nam)
      #   unless !!dramas[my_match[1]]
      #     dramas[my_match[1]] = { nam: my_match[1], size: 1000, children: [{nam: my_match[2], size: (caps.length * 1000), children: caps}]}
      #   else
      #     dramas[my_match[1]][:size] += 1000
      #   end
      # else
        h[:children].push({name: n.nam, size: (caps.length * 100) , children: caps}) if caps.length  > 0
      #end
    end
    dramas.keys.each{|k| h[:children].push dramas[k]}
    h
  end

  # Still needed?
  def is_series?
    !!self.nam.match(/(.+)\.(\d+_\d+x\d+)/)
  end

  def as_json(options={})
    if !!options[:search]
      caps = get_caps_by_search(options[:search]).map{|i| {id: i.id, cap: i.cap}}
    else
      caps = []
    end
    {id: id, name: nam, title: title, last_cap_stop: last_cap_stop, caps: caps, size: (caps.count * 1000), level: self.level, slug: self.slug}
  end

end
