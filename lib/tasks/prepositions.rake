
task :import_prepositions => [:environment] do
  language= Lng.where(%Q/lng="#{ENV['language']}"/).first
  basedir = Rails.root.to_s + "/lib/text_files/prepositions"

   path = basedir + "/#{language.lng.downcase!}_prepositions.txt"
   print path
   file = File.new(path, "r")
   while (line = file.gets)
   line= line.gsub(/\n/,"")
   line= line.gsub(/\r/,"")
   puts line

   Prep.find_or_initialize_by(:prep=>line, :lng_id=>language.id).save!
   # c=c+1
  end
end
