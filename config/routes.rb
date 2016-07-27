Rails.application.routes.draw do

  get 'spreadsheet/index'

  mount ActionCable.server => '/cable'

end
