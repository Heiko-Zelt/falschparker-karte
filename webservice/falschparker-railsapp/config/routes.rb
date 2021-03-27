Rails.application.routes.draw do
  get 'gis/info'
  get 'gis/boundary'
  get 'gis/bundeslaender'
  get 'gis/regierungsbezirke'
  get 'gis/grossstaedte'
  get 'gis/mittlere_gemeinden'
  get 'gis/count'
  get 'gis/charge_types'
  get 'gis/notices'
end
