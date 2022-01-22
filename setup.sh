docker-compose exec web bundle exec rake db:drop
docker-compose exec web bundle exec rake db:create
docker-compose exec web bundle exec rake db:migrate
docker-compose exec web rake add_languages

docker-compose exec web rake import_verbs cod=por_br --trace
docker-compose exec web rake import_verbs cod=kor --trace
docker-compose exec web rake import_verbs cod=jpn  --trace
docker-compose exec web rake import_verbs cod=tur  --trace
docker-compose exec web rake import_verbs cod=fra  --trace
docker-compose exec web rake import_verbs cod=spa  --trace

docker-compose exec web rake import_prepositions language=spanish --trace
docker-compose exec web rake import_prepositions language=french --trace
docker-compose exec web rake import_english_verbs --trace
docker-compose exec web rake import_english_idioms --trace
# docker-compose exec web rake import_turkish_tenses cod=tur --trace
# docker-compose exec web rake import_turkish_verbs cod=tur --trace


docker-compose exec web rake import_prepositions language=korean --trace
docker-compose exec web rake import_prepositions language=portuguese --trace
docker-compose exec web rake import_prepositions language=turkish --trace
docker-compose exec web rake import_prepositions language=japanese --trace


docker-compose exec web rake import_movies file=el.clan language=spa --trace
docker-compose exec web rake import_movies file=relatos.salvajes language=spa --trace
docker-compose exec web rake import_movies file=nueve.reinas language=spa --trace
docker-compose exec web rake import_movies file=maria.llena.de.gracia language=spa --trace
docker-compose exec web rake import_movies file=museo language=spa --trace
docker-compose exec web rake import_movies file=belle.de.jour language=fra --trace
docker-compose exec web rake import_movies file=amour.et.turbulences language=fra --trace
docker-compose exec web rake import_movies file=red.sorghum language=chi_hans --trace
docker-compose exec web rake import_movies file=to.live language=chi_hans --trace
docker-compose exec web rake import_movies file=mr.six language=chi_hans --trace
docker-compose exec web rake import_movies file=red.cliff language=chi_hans --trace
docker-compose exec web rake import_movies file=the.great.hypnotist language=chi_hans --trace
docker-compose exec web rake import_movies file=charade language=eng --trace
docker-compose exec web rake import_movies file=patterns language=eng --trace
docker-compose exec web rake import_movies file=the.legend.of.muay.thai language=tha --trace
docker-compose exec web rake import_movies file=pee.mak language=tha --trace
docker-compose exec web  rake import_movies file=coisa.ruim language=por_br --trace
docker-compose exec web  rake import_movies file=squid.game.S1E1 language=kor --trace
docker-compose exec web  rake import_movies file=evim.sensin language=tur --trace
docker-compose exec web  rake import_movies file=love.of.my.life language=jpn --trace

docker-compose exec web rake assign_languages_to_names
docker-compose exec web bundle exec rake ts:rebuild
docker-compose exec web bundle exec rake create_clauses language=fra --trace
docker-compose exec web bundle exec rake create_clauses language=spa --trace
docker-compose exec web bundle exec rake create_clauses language=por_br --trace
docker-compose exec web bundle exec rake create_clauses language=kor --trace
docker-compose exec web bundle exec rake create_clauses language=tur --trace
docker-compose exec web bundle exec rake create_clauses language=jpn --trace
docker-compose exec web bundle exec rake create_english_clauses --trace
docker-compose exec web bundle exec rake scan_idioms --trace

docker-compose exec web bundle exec rake scan_prepositions language=spa --trace
docker-compose exec web bundle exec rake scan_prepositions language=fra --trace
docker-compose exec web bundle exec rake scan_prepositions language=kor --trace
docker-compose exec web bundle exec rake scan_prepositions language=por_br --trace
docker-compose exec web bundle exec rake scan_prepositions language=tur --trace
docker-compose exec web bundle exec rake scan_prepositions language=jpn --trace

#docker-compose exec web rake import_chinese_grams --trace
docker-compose exec web rake import_kanji
docker-compose exec web rake import_hsk
docker-compose exec web rake count_chinese
docker-compose exec web rake chinese_idioms
