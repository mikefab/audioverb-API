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
  get 'nam/:nam'                => 'nams#caps_by_nam'
  get 'nams/'                => 'nams#all'
  get 'nams/:language'                        => 'nams#list'
  get 'grams/list/:gram'                       => 'home#grams'
  get 'level/:gram/:level/:lng/:media'         => 'home#level'
  get 'verbs_for_name/:nam' => 'nams#verbs_for_nam'
  get 'verb_for_name/:nam/:verb' => 'nams#conjugations_for_nam'
  get 'caps/:nam/:num'                         => 'caps#cap_by_nam_num'
  get 'caps/:nam/:num(/:num_records)'          => 'caps#cap_by_nam_num_group'
  get 'search/:lng/:media/:search'             => 'nams#search_by_nam'
  get 'search/:lng/:search'                    => 'nams#search'
#  get 'tenses/:language/:media'                => 'home#tenses'
  get 'tenses/:language'                => 'home#tenses'
  get 'tense/:tense'                           => 'home#tense'
  get 'tense/:tense/verb/:verb'                => 'home#conjugation'
  get 'search/caps/:lng/:search/:nam'          => 'nams#search_caps_nam'
  get 'combine'                                => 'orders#combine' # for concating png and mp3 files on the fly
  get 'combine/:format/:source/:name/(/:num/):start/:stop.:extenstion' => 'orders#combine' # for concating png and mp3 files on the fly
  # get 'cuts/:name/:num/:start/:stop/:user_id' => 'home#save_cut'
  post 'cuts' => 'home#save_cut'
end
