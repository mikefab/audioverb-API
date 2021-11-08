class Cla < ApplicationRecord
  #attr_accessible :cla, :lng_id, :mood_id, :tense_id, :tiempo_id, :verb_id

   #has_and_belongs_to_many :lngs, :join_table => "clas_lngs"
   belongs_to :lng
   has_and_belongs_to_many :caps, :join_table => "caps_clas"
   #has_and_belongs_to_many :nams, :join_table => "clas_nams"
   belongs_to :verb
   belongs_to :tense

   #has_and_belongs_to_many :tags, :join_table => "clas_tags"
   #has_many :taggings, :as => :taggable, :dependent => :destroy, :include => :tag, :class_name => "ActsAsTaggableOn::Tagging", :conditions => "taggings.taggable_type = 'Cla'"
   #has_many :tags, :through => :taggings, :source => :tag, :class_name => "ActsAsTaggableOn::Tag",  :conditions => "taggings.taggable_type = 'Cla'"
end
