Rails.application.routes.draw do

  get 'spreadsheet/index'

  mount ActionCable.server => '/cable'

  root 'spreadsheet#index'

end
