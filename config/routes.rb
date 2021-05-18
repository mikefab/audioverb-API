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
  get 'nams/'                => 'nams#all'
  get 'caps/:nam/:num'                         => 'caps#cap_by_nam_num'
  get 'search/:lng/:media/:search'                    => 'nams#search_by_nam'
  get 'search/:lng/:search'                    => 'nams#search'
#  get 'tenses/:language/:media'                => 'home#tenses'
  get 'tenses/:language'                => 'home#tenses'
  get 'tense/:tense'                           => 'home#tense'
  get 'tense/:tense/verb/:verb'               => 'home#conjugation'
  get 'search/caps/:lng/:search/:nam'          => 'nams#search_caps_nam'
  get 'combine'                                => 'orders#combine' # for concating png and mp3 files on the fly
  get 'combine/:format/:source/:name/:start/:stop.:extenstion' => 'orders#combine' # for concating png and mp3 files on the fly
end
