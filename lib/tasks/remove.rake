
task :remove_cuts=>[:environment] do
  Cut.all.each do |cut|
    caps = Cap.where(id: cut.cap_id)
    if (caps.length === 0) then
      puts "Destroy #{cut.id} with #{cut.cap_id} because no cap"
      cut.destroy!
    else
      cap = caps.first
      if (cap.num.to_i != cut.num.to_i) then
        puts "Destroy #{cut.id} because nums don't match: #{cap.num.to_i} != #{cut.num.to_i}"
        cut.destroy!
      else
        puts "GOOD: #{cap.num.to_i} #{cut.num.to_i}"
      end
    end
  end
end

task :remove_clips=> [:environment] do
  Nam.all.each do |n|

    cap =  n.caps.first
    temp_nam = n.nam.gsub(/\s+/, '_')
    dir = "public/mp3/movies/#{temp_nam}/"
    nums = []

    # Remove beginning space
    if cap.start > 5
      i = 1
      while i < (cap.start - 5) do
        temp_i = i%1==0 ? i.to_int : i
        file = "public/mp3/movies/#{temp_nam}/#{temp_i}_#{temp_nam}.mp3"
        File.delete(file) if File.exist?(file)
        #puts "rm public/mp3/movies/#{temp_nam}/#{temp_i}_#{temp_nam}.mp3"
        i+=0.5
      end

      # Remove end space
      Dir.entries(dir).select {
        |f|
        name = f.split('_')[0]
        if name.match(/\d/) then
          nums.push(name.to_f)
        end
      }
      #puts "#{temp_nam} #{n.caps.last.stop} #{nums.sort().last}"
      last_clip = nums.sort().last
      last_cap_stop = n.caps.last.stop

      if (last_clip  - last_cap_stop) > 5 then
         i = last_cap_stop + 5
         while i <= last_clip do
          temp_i = i%1==0 ? i.to_int : i
          file =  "public/mp3/movies/#{temp_nam}/#{temp_i}_#{temp_nam}.mp3"
           #puts "rm #file}"
           File.delete(file) if File.exist?(file)
           i+=0.5
         end
      end


      # Remove middle

      ActiveRecord::Migration.execute("select start, stop, gap from (SELECT low.nam_id,
           low.num               AS low_num,
           high.num              AS high_num,
           low.stop as stop,
           high.start as start,
           high.start - low.stop AS gap,
           low.cap
    FROM   caps low,
           caps high
    WHERE  low.nam_id = #{n.id}
           AND high.start = (SELECT start
                             FROM   caps
                             WHERE  num > low.num
                                    AND nam_id = low.nam_id
                             ORDER  BY num
                             LIMIT  1)
           AND low.nam_id = high.nam_id) as thing where gap > 15;").each do |c|
        start = c[1].to_i + 5
        stop = c[0].to_i - 5
        gap = c[2]
        i = start
        while i <= stop do
          temp_i = i%1==0 ? i.to_int : i
          file = "public/mp3/movies/#{temp_nam}/#{temp_i}_#{temp_nam}.mp3"
          File.delete(file) if File.exist?(file)
          #puts "#{c[1]} #{c[0]} rm "
          i += 0.5
        end
      end
    end
  end
end

task :remove_name => [:environment] do
  puts "#{ENV['nam']} !!!"
  nam    = Nam.find_by_nam(ENV['nam'])
  print nam.id
  clas_to_delete=Hash.new()

  #idos_lngs #You can't reverse this. Just run scan idioms again
  nam_lngs    = Hash.new()
  nam.lngs.each do |l|
    nam_lngs[l.id]=1
  end
  # ActiveRecord::Migration.execute("select cla_id from clas_nams where nam_id=#{nam.id}").each do |c|
  #   cla = Cla.find(c[0])
  #   seen_lngs  = Hash.new()
  #   cla.nams.each do |n|
  #     unless n == nam then
  #       n.lngs.each do |l|
  #         seen_lngs[l.id]=1
  #       end #end nam.lngs loop
  #     end #end if not nam to be removed
  #   end #nam loop perl cla
  #   nam_lngs.each do |k,v|
  #     unless seen_lngs[k] then
  #       print "delete from clas_lngs where cla_id=#{cla.id} and lng_id=#{k} #{seen_lngs}\n"
  #       ActiveRecord::Migration.execute("delete from clas_lngs where cla_id=#{cla.id} and lng_id=#{k}")
  #     end
  #   end
  #     print "#{cla.cla} -- don't delete from clas where cla_id=#{cla.id}; ...#{seen_lngs.size}\n"  if seen_lngs.size>0
  #     clas_to_delete[cla.id]=1 if seen_lngs.size==0
  # end #clas loop per nam


  ActiveRecord::Migration.execute("select voc_id from nams_vocs where nam_id='#{nam.id}''").each do |v|
#    print "#{voc.voc}\n"
    voc = Voc.find(v[0])
    seen_lngs  = Hash.new()
    voc.nams.each do |n|
      unless n == nam then
        n.lngs.each do |l|
          seen_lngs[l.id]=1
        end #end nam.lngs loop
      end #end if not nam to be removed
    end #nam loop perl cla
    nam_lngs.each do |k,v|
      unless seen_lngs[k] then
        print "#{voc.voc} delete from lngs_vocs where voc_id=#{voc.id} and lng_id=#{k}\n"
        ActiveRecord::Migration.execute("delete from lngs_vocs where voc_id=#{voc.id} and lng_id=#{k}")
      end
    end

  end #clas loop per nam


#  clas_lngs
#  lngs_vocs
  #caps
  #subs
  ActiveRecord::Migration.execute("delete from caps where nam_id = #{nam.id}")
  ActiveRecord::Migration.execute("delete from subs where nam_id = #{nam.id}")


  #caps_clas
  #caps_vocs
  Nam.find(nam.id).caps.each do |c|
     ActiveRecord::Migration.execute("delete from caps_clas where cap_id = #{c.id}")
     ActiveRecord::Migration.execute("delete from caps_vocs where cap_id = #{c.id}")
  end
  #clas_nams
  #nams_vocs
  # ActiveRecord::Migration.execute("delete from clas_nams where nam_id = #{nam_id}")
  ActiveRecord::Migration.execute("delete from nams_vocs where nam_id = #{nam.id}")

  #lngs_nams
  ActiveRecord::Migration.execute("delete from lngs_nams where nam_id = #{nam.id}")

  clas_to_delete.each do |k,v|
    ActiveRecord::Migration.execute("delete from clas where id=#{k};")
  end

  ActiveRecord::Migration.execute("delete from nams where id = #{nam.id}")
  ActiveRecord::Migration.execute("delete from cuts where nam = #{nam.nam}")

end
