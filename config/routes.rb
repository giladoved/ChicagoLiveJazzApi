Rails.application.routes.draw do
  scope '/api' do
    scope '/greenmill' do
      get '/' => 'green_mill#index'
      get '/' => 'green_mill#video'
    end
  end
end
