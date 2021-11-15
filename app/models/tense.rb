class Tense < ApplicationRecord
  #attr_accessible :lng_id, :mood_id, :priority, :tense, :tiempo_id
	belongs_to :mood
	def self.tense_verbs(tense_id)
	  if Rails.cache.read("tense_#{tense_id}")
	   return Rails.cache.read("tense_#{tense_id}")
	  else
	    infinitive = Hash.new()
			Cla.where(tense_id: tense_id).order(:verb_id).each do |c|
        infinitive[c.verb.verb] = Array.new() if !infinitive[c.verb.verb]
        infinitive[c.verb.verb] << c.cla if infinitive[c.verb.verb]
      end
	    return Rails.cache.fetch("tense_#{tense_id}", :expires_in =>3.days){infinitive}
	  end
	end

  def self.tenses(lng_id)
    title="tenses_#{lng_id}"
    if Rails.cache.exist?(title) then
     return Rails.cache.read(title)
    else
      moods=Hash.new()
      # Cla.where(lng_id: lng_id).each do |c|
      #   tenses[Tense.find(c.tense_id).tense]=1
      # end
			ActiveRecord::Migration.execute("select distinct tense_id from clas where lng_id=#{lng_id}").each do |id|
				ActiveRecord::Migration.execute("select mood, tense from tenses join moods on tenses.mood_id = moods.id where tenses.id=#{id[0]}").each do |mood, tense|
        	if moods[mood] then
						moods[mood] << tense
					else
						moods[mood] = [tense]
					end
				end


	    end

     Rails.cache.write(title,moods)
      return moods
     end
  end
end
