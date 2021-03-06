
U = {
  collections: {},
  views: {
    addritems: {},
    cities: {},
    days: {},
    galleries: {},
    places: {},
    reports: {},
    sites: {},
    users: {},
    venues: {},
    videos: {},
    welcome: {}
  },
  models: {},
  dropbox: {},
  log: function(args) {
    console.log(args);
    $("#log_main div").append(args);
  },
  manager: {
    views: {
      galleries: {}
    }
  }
}

CanvasOps = {
    trash: 'trash'
}
Utils = {}
// header footer
HF = {}

Models = {}
Collections = {}
Views = {
  Addritems: {},
  Cities: {},
  CitiesUsers: {},
  Days: {},
  Galleries: {},
  Places: {},
  Reports: {},
  Sites: {},
  Users: {},
  Venues: {},
  Videos: {}
}
Manager = {
  Collections: {},
  Views: {
    Galleries: {},
    Reports: {},
    Welcome: {}
  },
  Models: {}
}

App = {
  Models: {},
  Collections: {},
  Routers: {},
  Views: {
    Addritems: {},
    Cities: {}, 
    City: {},
    CitiesUsers: {},
    Reports: {},
    Sites: {},
    Users: {},
    Venues: {},
    Videos: {}
  }
}

MyApp = new Backbone.Marionette.Application();

MyApp.addRegions({
  right_region: ".right-container .inner",
  left_region: ".left-container .inner",

  right_menu: ".right-menu",
  left_menu: ".left-menu",

  manager_menu: '.manager-menu',
  manager_region: '.manager-region'
  
});







