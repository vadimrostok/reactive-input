# TODO: prefixes for helpers' names
if Meteor.isClient

  @ReactiveInput = @ReactiveInput or {}
  @ReactiveInput.generateHelpers = ( tpl, reactiveModel ) ->
    obj = Tracker.nonreactive => reactiveModel.get()
    tplName = tpl.view.name.split(".")[1]

    # generate helpers for reactive inputs
    # do not forget about helpers' names collisions
    generatedHelpers = {}
    tpl.reactiveInputs = {}
    for field in Object.keys obj
      tpl.reactiveInputsFor = field
      tpl.reactiveInputs[field] = new ReactiveVar obj[field]
      (( field ) ->
        generatedHelpers["#{field}Connection"] = -> Template.instance().reactiveInputs[field]
        generatedHelpers[field] = -> Template.instance().reactiveInputs[field].get()
      )( field )
    Template[tplName].helpers generatedHelpers

    for field in Object.keys (Tracker.nonreactive => reactiveModel.get())
      ((field) -> tpl.autorun ->
        model = Tracker.nonreactive => reactiveModel.get()
        model[field] = tpl.reactiveInputs[field].get()
        reactiveModel.set model)(field)

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
  connectionValue: ->
    Template.instance().connection.get()

commonEvents = ->
  "input *, autocompleteselect *": ( ev, tpl ) -> _.defer =>
    tpl.connection.set $(ev.currentTarget).val()

templateNames = [
  "reactiveInputTagInput",
  "reactiveInputTagSelect",
  "reactiveInputTagTextarea"
]

for key in templateNames
  Template[key].created = commonCreated()
  Template[key].rendered = commonRendered()
  Template[key].helpers commonHelpers()
  Template[key].events commonEvents()

Template.reactiveInputTagSelect.helpers
  options: ->
    options = Template.instance().data.options
    options?.get?() or options
  selected: ( value ) ->
    if "#{value}" is "#{Template.instance().connection.get()}"
      "selected"
    else ""
