class Tense < ApplicationRecord
  #attr_accessible :lng_id, :mood_id, :priority, :tense, :tiempo_id

	def self.return_tense_verbs(tense_id,native_id)
	  if Rails.cache.read("tense_native-#{tense_id}#{native_id}")

	   return Rails.cache.read("tense_native-#{tense_id}#{native_id}")
	  else
	    infinitive = Hash.new()
      # Why do this? You know what the site_language_id is based on the tense
	    #check if native_id is site language
	   #  if native_id.to_i==site_language_id.to_i then
				# Cla.where(%Q/lng_id=#{native_id} and tense_id=#{tense_id}/).order(:verb_id).each do |c|
	   #      infinitive[c.verb.verb] = Array.new() if !infinitive[c.verb.verb]
	   #      infinitive[c.verb.verb] << c.cla if infinitive[c.verb.verb]
	   #    end
	   #  else
				Cla.joins(:lngs).where(%Q/clas.id=clas_lngs.cla_id and clas.tense_id=#{tense_id}  and clas_lngs.lng_id=#{native_id}/).order(:verb_id).each do |c|
	        infinitive[c.verb.verb] = Array.new() if !infinitive[c.verb.verb]
	        infinitive[c.verb.verb] << c.cla if infinitive[c.verb.verb]
	      end
	    #end
      infinitive
	    return Rails.cache.fetch("tense_native-#{tense_id}#{native_id}", :expires_in =>3.days){infinitive}
	  end
	end

  def self.get_tenses_for_native(native_id,site_lng_id)
    title="tenses_#{native_id}_#{site_lng_id}"
    if Rails.cache.exist?(title) then
     return Rails.cache.read(title)
    else
      tenses=Hash.new()
      if native_id.to_i == site_lng_id.to_i #if checking site language then give all tenses for that language
        Cla.where("lng_id=#{site_lng_id}").each do |c|
          tenses[Tense.find(c.tense_id).tense]=1
        end
      else #Checking site language against foreign language
        Cla.joins(:lngs).where("clas_lngs.lng_id =#{native_id} and clas.lng_id=#{site_lng_id}").each do |c|
          tenses[Tense.find(c.tense_id).tense]=1
        end
      end
     Rails.cache.write(title,tenses)
      return tenses
     end
  end
end
