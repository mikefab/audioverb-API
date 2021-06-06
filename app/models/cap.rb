class Cap < ApplicationRecord
  require 'ostruct'
   has_many    :subs
   belongs_to  :nam
   belongs_to  :src
   has_many    :lngs, :through => :nam
   has_and_belongs_to_many :clas, :join_table => "caps_clas"
   has_many    :cuts
   has_many    :trans
   has_and_belongs_to_many :vocs, :join_table => "caps_vocs"
   def to_point_five(num)
     num   = (num * 10).round.to_f / 10
     num   = num.to_s
     tenth = num.match(/\.\d/).to_s.gsub(/\./,"").to_i
     num  = num.to_i
     num  +=  1 if tenth > 5
     num  = num + 0.5 if tenth < 5
     num
   end

   def start
     # to_point_five((super.to_f - self.nam.pad_start.to_f))
     to_point_five((super.to_f - 0.5))
   end

   def stop
    #  to_point_five((super.to_f + self.nam.pad_end.to_f))
    to_point_five((super.to_f + 0.5))
   end

   def all_subs
     self.subs << self.sub
   end

   def next
     Cap.where("id > ?", id).order("id ASC").first || Cap.first
   end

   def previous
     Cap.where("id < ?", id).order("id DESC").first || Cap.last
   end

   def group(num_records)
     num_records = num_records ? num_records : 3
     if num_records > 10 then
       num_records = 5
     end
     def padGroup(node, target_num, direction, times=num_records, ary=[], index=0)
       if index === times or wrongDirection(direction, target_num, node.num)
         return ary
       else
         index+=1
         if direction === 1
           ary.push(node)
         else
           ary = [node] + ary
         end

         return padGroup(
           direction ===1 ? node.next : node.previous,
           target_num,
           direction,
           times,
           ary,
           index)
       end
       return ary
     end

     def wrongDirection(direction, target_num, current_num)
       if direction === 1 && target_num > current_num
         return true
       end
       if direction === 0 && target_num < current_num
         return true
       end
      return false
     end

     ary = padGroup(self, self.num, 0, num_records)
     padGroup(self, self.num, 1, num_records, ary).uniq!
   end


   def get_array_of_compound_words(sentence, entries)
     sentence = sentence.split(//);
     h_o_e    = Hash.new
     entries.each do |e|
       sentence.each_with_index do |character, i|
         if sentence[i..(i + (e.length - 1))].join("").match(/#{e}/)
           h_o_e[i] = e
           (i).upto(i+ (e.length - 1)){|i| sentence[i] = nil}
         end
       end
     end

     a = Array.new
     i = 0
     while i < (sentence.count - 1) do
       if h_o_e[i]
         a << h_o_e[i]
         i += (h_o_e[i].length - 1)
       elsif
         sentence[i]
           a << sentence[i]
           i += 1
       else
         i+= 1
       end
     end
     a
   end


   def entries
     entries         = Hash.new
     entry_matches   = Array.new
     self.cap.split(//).each_with_index do |character, index|
       if Kanji.find_by_kanji(character) && Kanji.find_by_kanji(self.cap[index+1])
         Entry.where("entry like '#{character}#{self.cap[index+1]}%'").each{|entry| entries[entry] = 1}
       end
     end
     entries.each do |k,v|
       entry_matches << k if self.cap.match(/#{k.entry}/)
     end
     #a = get_array_of_compound_words(self.cap, entry_matches.map(&:entry).sort_by {|x| x.length}.reverse)
     return entry_matches
   end

   def cap_vocs
     self.vocs
   end

   def last_cap_stop
     self.nam.caps.last.stop
   end

   def as_json(options={})
     #super(:include => [:entries, :subs, :nam, :cuts])
     super(options.merge( :methods => [:last_cap_stop], :include => [:cap_vocs, :nam, :cuts]))
     #super(:include => [:cap_vocs, :nam, :cuts])
   end

   # def subs
   #   super << self.sub if self.sub
   # end

   # def sub
   #   english_id = 122
   #   subs = Array.new
   #   [0.5, 1, 2, 5].each do |diff|
   #     subs = Sub.find_by_sql("SELECT sub,nam_id,num,id from subs where nam_id=#{self.nam_id} and lng_id=#{english_id}  GROUP BY start HAVING ABS(start - #{self.start}) <= #{diff} limit 1;")
   #     break if subs.first
   #   end

   #   #subs.first.cap_id = self.id
   #   subs.first
   # end
 end
