Template.reactiveInput.rendered = ->
  template = switch @data.input
    when "textarea" then Template.reactiveInputTagTextarea
    when "select" then Template.reactiveInputTagSelect
    else Template.reactiveInputTagInput
  templateData = _.omit @data, ["input"]

  Blaze.renderWithData template, templateData, @firstNode

commonCreated = -> ->
  @connection = @data.connection

commonRendered = -> ->
  $(@firstNode).attr "type", @data.input

  attrs = _.omit @data, ["connection"]
  for key, val of attrs
    $(@firstNode).attr key, val

commonHelpers = ->
  connectionValue: -> Template.instance().connection.get()

commonEvents = ->
  "input *": ( ev, tpl ) ->
    tpl.connection.set $(ev.currentTarget).val()

Template.reactiveInputTagInput.created = commonCreated()
Template.reactiveInputTagInput.rendered = commonRendered()
Template.reactiveInputTagInput.helpers commonHelpers()
Template.reactiveInputTagInput.events commonEvents()

Template.reactiveInputTagSelect.created = commonCreated()
Template.reactiveInputTagSelect.rendered = commonRendered()
Template.reactiveInputTagSelect.helpers _.extend commonHelpers(),
  selected: ( value ) ->
    if "#{value}" is "#{Template.instance().connection.get()}"
      "selected"
    else ""

Template.reactiveInputTagSelect.events commonEvents()

Template.reactiveInputTagTextarea.created = commonCreated()
Template.reactiveInputTagTextarea.rendered = commonRendered()
Template.reactiveInputTagTextarea.helpers commonHelpers()
Template.reactiveInputTagTextarea.events commonEvents()
