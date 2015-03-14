# TODO: controinng attr: input -> type
if Meteor.isClient

  @ReactiveInput = @ReactiveInput or {}
  @ReactiveInput.generateHelpers = ( tpl, reactiveModel ) ->
    obj = Tracker.nonreactive => reactiveModel.get()
    tplName = tpl.view.name.split(".")[1]

    # generate helpers for reactive inputs
    # do not forget about helpers' names collisions
    generatedHelpers = {}
    tpl.reactiveInputs ?= {}

    for field in Object.keys obj
      tpl.reactiveInputs[field] = new ReactiveVar obj[field]

      (( field ) ->
        generatedHelpers["#{field}Connection"] = -> Template.instance().reactiveInputs[field]
        generatedHelpers[field] = -> Template.instance().reactiveInputs[field].get()
      )( field )

    for key, helper of generatedHelpers
      continue if Template[tplName].generatedHelpers?[key]

      obj = {}
      obj[key] = helper
      Template[tplName].helpers obj

    Template[tplName].generatedHelpers ?= {}
    _.extend Template[tplName].generatedHelpers, generatedHelpers

    for field in Object.keys (Tracker.nonreactive => reactiveModel.get())
      tpl.autorun (( field ) -> ->
        model = Tracker.nonreactive => reactiveModel.get()
        model[field] = tpl.reactiveInputs[field].get()
        reactiveModel.set model
      )( field )

Template.reactiveInput.rendered = ->
  template = switch @data.input
    when "textarea" then Template.reactiveInputTagTextarea
    when "select" then Template.reactiveInputTagSelect
    else Template.reactiveInputTagInput
  templateData = _.omit @data, ["input"]

  value = @data.connection.get()
  editMode = not value or
    value.trim?() is "" or
    @data.editableStartState or
    not @data.isEditable
  templateData.editMode = new ReactiveVar editMode

  Blaze.renderWithData template, templateData, @firstNode

commonCreated = -> ->
  @editMode = @data.editMode
  @connection = @data.connection

commonRendered = -> ->
  $(@firstNode).attr "type", @data.input

  attrs = _.omit @data, ["connection"]
  for key, val of attrs
    $(@firstNode).attr key, val

commonHelpers = ->
  isEditMode: -> Template.instance().editMode.get()
  connectionValue: ->
    Template.instance().connection.get()

commonEvents = ->
  "input *, autocompleteselect *": ( ev, tpl ) -> _.defer =>
    tpl.connection.set $(ev.currentTarget).val()

  "click span, mouseover span": ( ev, tpl ) ->
    Template.instance().editMode.set true
    _.defer -> tpl.$("input, select").focus()

  "blur *, keyup *, autocompleteclose *": ( ev, tpl ) ->
    return unless ev.keyCode is 13 or not ev.keyCode
    return if $(ev.currentTarget).val().trim() is ""

    if Template.instance().data.isEditable
      Template.instance().editMode.set false

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
