# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

rails new audioverb -d mysql

rails g foundation:install rake db:create rails g backbone:install

rails g model Lng lng:string cod:string

rails g model Voc voc:string freq:float gram:integer lng_id:integer rank:integer raw:integer

rails g model Kanji kanji:string pinyin:string –no-timestamps

rails g model Src src:string:index lng_id:integer:index ser:string:index

rails g model Nam nam:string:index lng_id:integer:index duration:string src_id:integer:index season:string:index episode:string:index upldr:string:index title:string:index

rails g model Cap cap:string:index lng_id:integer:index num:integer:index start:string:index stop:string nam_id:integer:index src_id:integer:index wcount:integer ccount:integer

rails g model Sub sub:string cap_id:integer:index lng_id:integer num:integer start:string stop:string nam_id:integer src_id:integer clng_id:integer:index

rails g model LngsVocs lng_id:integer:index voc_id:integer:index seen:integer olng_id:integer:index —no-timestamps –no-id

rails g model NamsVocs nam_id:integer:index voc_id:integer:index –no-timestamps –no-id

rails g model LngsNams lng_id:integer:index nam_id:integer:index –no-timestamps –no-id

rails generate acts_as_taggable_on:migration

rails g model Entry kanji_id:integer:index entry:string:index –no-timestamps

rails g model Cla cla:string:index lng_id:integer:index mood_id:integer tense_id:integer tiemo_id:integer verb_id:integer

rails g model Def kanji_id:integer:index entry_id:integer:index def:text:index voc_id:integer rank:integer:index pos:string{10}:index gram:string{10}:index level:string{5}:index –no-timestamps

rails g model CapsClas cap_id:integer:index cla_id:index –no-timestamps –no-id

rails g model ClasLngs cla_id:integer:index lng_id:integer:index o_lng:integer:index
rails g model Mood mood:string:index lng_id:integer:index priority:integer:index
rails g model Cut num:integer:index start:string:index stop:string cap_id:integer:index

rails g model Tiempo tiempo:string:index lng_id:integer:index priority:integer:index
rails g model Tense tense:string:index mood_id:integer:index tiempo_id:integer:index lng_id:integer:index priority:integer:index

rails g model Con con:string:index con_id:integer:index verb_id:integer:index tense_id:integer:index mood_id:integer:index tiempo_id:integer:index lng_id:integer:index priority:integer:index

rails g model Verb verb:string:index lng_id:integer:index

rails g model last num:integer kind:string bench:string

rails g model Act user_id:integer:index user_name:string cap_id:integer num:integer nam:string:index

rake db:migrate

mysql -u root audioverb_development -e "ALTER TABLE entries CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;"
mysql -u root audioverb_development -e "ALTER TABLE defs CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;"

In console: Lng.seed_data()

bundle exec rake import_free_dictionary –trace
bundle exec rake import_verbs language=spanish
bundle exec rake import_verbs language=spanish
bundle exec rake create_clauses language=spa

rails g controller home
