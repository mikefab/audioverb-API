ThinkingSphinx::Index.define :cap, :with => :active_record do
  indexes cap
  indexes :id
  #indexes src.cat, :as => :cat
  #indexes src.ser, :as => :ser
  # indexes nam.episode, :as => :episode
  # indexes nam.season, :as => :season
  # indexes nam.upldr, :as => :upldr
  indexes nam.title, :as => :title
  # indexes :cat
  has lngs(:id), :as => :lng_ids
  has nam_id, lng_id, num
end
