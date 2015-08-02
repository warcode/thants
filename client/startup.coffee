Meteor.startup ->
  Deps.autorun ->
    document.title = "thants : " + Session.get('channel')
    return
  return