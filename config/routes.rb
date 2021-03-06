Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  # You can have the root of your site routed with "root"
  root 'home#index'
    namespace :api do
      namespace :v1 do
        resources :lists
        resources :items
      end
    end
  get 'languages' => 'lngs#languages'
  get 'yu/:kind' => 'entries#yu'
  get 'yu/:kind/media/:media' => 'entries#yu_by_media'
  # get 'duanyu/:language                => 'entries#duanyu'
  # get 'duanyu/media/:media'                => 'entries#duanyu_by_media'


  get 'preps/:lng'                => 'preps#preps'
  get 'preps/nam/:nam'                => 'preps#preps_by_nam'

  get 'idioms/:lng'                => 'idos#idos'
  get 'idioms/nam/:nam'                => 'idos#idos_by_nam'

  get 'nam/:nam'                => 'nams#caps_by_nam'

  get 'nams/'                => 'nams#all'
  get 'nams/:language'                        => 'nams#list'
  get 'grams/list/:gram'                       => 'home#grams'
  get 'level/:gram/:level/:lng/:media'         => 'home#level'
  get 'verbs_for_name/:nam' => 'nams#verbs_for_nam'
  get 'verbs/:lng' => 'verbs#verbs'
  get 'verb_for_name/:nam/:verb' => 'nams#conjugations_for_nam'
  get 'conjugations/:verb/:language' => 'verbs#conjugations'
  get 'caps/:nam/:num'                         => 'caps#cap_by_nam_num'
  get 'caps/neighbors/:nam/:num'          => 'caps#neighbor_nums'
  get 'caps/:nam/:num(/:num_records)'          => 'caps#cap_by_nam_num_group'
  get 'search/media/:media/:search'             => 'nams#search_by_nam'
  get 'search/:lng/:search'                    => 'nams#search'
#  get 'tenses/:language/:media'                => 'home#tenses'
  get 'tenses/:language'                => 'tenses#tenses'
  get 'language/:language/mood/:mood/tense/:tense/verb/:verb' => 'verbs#conjugation'
  get 'mood/:mood/tense/:tense' => 'tenses#tense'

  get 'search/caps/:lng/:search/:nam'          => 'nams#search_caps_nam'
  get 'combine'                                => 'orders#combine' # for concating png and mp3 files on the fly
  get 'combine/:format/:source/:name/(/:num/):start/:stop.:extenstion' => 'orders#combine' # for concating png and mp3 files on the fly
  # get 'cuts/:name/:num/:start/:stop/:user_id' => 'home#save_cut'
  get 'cuts/:nam'                                => 'cuts#cuts_by_nam' # for concating png and mp3 files on the fly
  post 'cuts' => 'cuts#save_cut'
end
