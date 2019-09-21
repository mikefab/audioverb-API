class Voc < ApplicationRecord
  has_and_belongs_to_many :nams, :join_table => "nams_vocs"
  #attr_accessible :freq, :gram, :lng_id, :rank, :raw, :voc


  def self.return_verbs(lng_id)
#    Cla.where(lng_id: lng_id).limit(100).map(&:verb).uniq.sort! { |a,b| a.verb.downcase <=> b.verb.downcase }
    Cla.where(lng_id: lng_id).limit(30).map(&:verb).uniq.sort! { |a,b| a.verb.downcase <=> b.verb.downcase }
  end

  # Return array of characters found in either all Chinese movies or in a specific Chinese movie title.
  # gram_type is 1 or 2 for monograms and bigrams
  def self.grams(gram_type,title_id)
   if Rails.cache.exist?("grams_#{gram_type}_#{title_id}") then
    return Rails.cache.read("grams_#{gram_type}_#{title_id}")
   end
    lng_id     = Lng.where(cod: 'chi_hans').first.id
    all_movies =  title_id.kind_of?(String) || title_id.kind_of?(NilClass)

    grams = movie_grams(gram_type, lng_id, all_movies)
    return Rails.cache.fetch("grams_#{gram_type}_#{title_id}", :expires_in => 3.days){grams.map{|k,v| k }}
  end

  def self.movie_grams(gram_type, lng_id, all_movies)
    count = 0
    grams = Hash.new()
    if all_movies #If title_id is string, then grab voc_ids for all movies
      #sql_statement = "select voc_id from lngs_vocs where olng_id=#{lng_id}  and lng_id=#{lng_id} order by voc_id;"
      sql_statement = "select voc_id from lngs_vocs, vocs where lngs_vocs.olng_id=#{lng_id} and lngs_vocs.lng_id=#{lng_id} and vocs.id = lngs_vocs.voc_id and vocs.gram = #{gram_type} order by lngs_vocs.voc_id;"
    else
      sql_statement = "select nams_vocs.voc_id from lngs_vocs,nams_vocs where olng_id=#{lng_id} and lngs_vocs.lng_id=#{lng_id} and nams_vocs.nam_id=#{title_id} and nams_vocs.voc_id=lngs_vocs.voc_id order by nams_vocs.voc_id;"
    end

    ActiveRecord::Migration.execute("#{sql_statement}").each do |voc|
      grams, count = determine_voc_gram_type(gram_type, voc, grams, count)
    end
    grams
  end

  def self.determine_voc_gram_type(gram_type, voc, grams, count)
    v = Voc.find(voc[0])
    if v.gram == gram_type.to_i || gram_type == 0
      count += 1
      grams[v.voc] = v.rank
    end
   	return grams, count
  end

  # Return array of characters found in either all Chinese movies or in a specific Chinese movie title.
  # gram_type is 1 or 2 for monograms and bigrams
  def self.level(gram, level,title_id)
   # if Rails.cache.exist?("level_#{gram}_#{level}_#{title_id}") then
   #  return Rails.cache.read("level_#{gram}_#{level}_#{title_id}")
   # end
    # all_movies =  title_id.kind_of?(String) || title_id.kind_of?(NilClass)
    # puts "!!!! #{title_id} #{all_movies}"
    grams = movie_level_grams(gram, level, 81, title_id)

    return Rails.cache.fetch("level_#{gram}_#{level}_#{title_id}}", :expires_in => 3.days){grams.map{|k,v| k }}
  end

  def self.movie_level_grams(gram, level, lng_id, movie)
    count     = 0
    grams     = Hash.new()
    level = level
    nam = Nam.where(nam: movie.gsub(/_/,' ')).first
    frag      = gram.to_i == 1 ? "vocs.gram = 1" : "CHARACTER_LENGTH(voc) > 1" # monograms or multigrams
    if movie.match(/all/) #If title_id is string, then grab voc_ids for all movies
      #sql_statement = "select voc_id from lngs_vocs where olng_id=#{lng_id}  and lng_id=#{lng_id} order by voc_id;"
      sql_statement = "select voc_id           from lngs_vocs,            vocs where #{frag} and lngs_vocs.olng_id=#{lng_id} and lngs_vocs.lng_id=#{lng_id} and vocs.id = lngs_vocs.voc_id and vocs.level = #{level} order by lngs_vocs.voc_id;"
    else
      #sql_statement = "select nams_vocs.voc_id from lngs_vocs, nams_vocs, vocs where #{frag} and lngs_vocs.olng_id=#{lng_id} and lngs_vocs.lng_id=#{lng_id} and nams_vocs.nam_id=#{nam.id} and nams_vocs.voc_id=lngs_vocs.voc_id and vocs.level = #{from}  order by nams_vocs.voc_id;"
      sql_statement = "select nams_vocs.voc_id from nams_vocs, vocs where #{frag} and vocs.lng_id=81 and nams_vocs.nam_id=#{nam.id} and nams_vocs.voc_id=vocs.id and vocs.level = #{level}  order by nams_vocs.voc_id;"
    end

    ActiveRecord::Migration.execute("#{sql_statement}").each do |voc|
      #puts "!!! #{voc}"
      grams, count = determine_voc_gram_type(0, voc, grams, count)
    end
    grams
  end

end
