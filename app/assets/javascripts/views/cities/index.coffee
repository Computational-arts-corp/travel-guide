$(document).ready ->

  Views.Cities.IndexItem = Backbone.Marionette.ItemView.extend
    model: Models.City
    template: '#cities_index_item-template'

  Views.Cities.Index = Backbone.Marionette.CollectionView.extend
    template: '#cities_index-template'
    itemView: Views.Cities.IndexItem

    events:
      'click a.cities-show-link': 'show_city'

    initialize: (item) ->
      this.collection = U.models.cities

    show_city: (item) ->
      U.models.city = new Models.City({ cityname: item.cityname })
      U.models.city.fetch
        success: ->
          U.views.city = new Views.Cities.Show
            model: U.models.city
          MyApp.right_region.show( U.views.city )

        
        
              