#TODO: move "editable" feature to separate package!

# There are two options how to connect reactiveInput with your model:
# 1: pass a connection parameter, which is a reactiveVar
# 2: pass a reactiveModel parameter and a fieldName parameter
#
# There are few "controlling" params:
# 1: type - which would be a input type
# 2: connection - reactveVar
# 3: reactiveModel + fieldName - instead of connection

Template.reactiveInput.rendered = ->
  # which input template to use?
  template = switch @data.type
    when "textarea" then Template.reactiveInputTagTextarea
    when "select" then Template.reactiveInputTagSelect
    else Template.reactiveInputTagInput

  # Model+fieldName were passed, create connection.
  if @data.reactiveModel and @data.fieldName
    modelData = Tracker.nonreactive => @data.reactiveModel.get()
    @data.connection = new ReactiveVar modelData[@data.fieldName]

  value = @data.connection.get()

  # Checkbox type needs special treatment.
  if @data.type is "checkbox" and value
    @data.checked = true

  # Edit mode (aka editable) as a secret extra feature, only those of you who
  # read this gonna know about it :) I'll remove it soon.
  editMode = not value or
    value.trim?() is "" or
    @data.editableStartState or
    not @data.isEditable
  @data.editMode = new ReactiveVar editMode

  Blaze.renderWithData template, @data, @firstNode

commonCreated = -> ->
  @editMode = @data.editMode
  @connection = @data.connection

  # Update reactiveModel (passed as a parameter) on connecion change
  # because in this case (reactiveModel passed) `connection` is a hidden state
  # so users don't have access to it.
  if @data.reactiveModel and @data.fieldName
    @autorun =>
      modelData = Tracker.nonreactive => @data.reactiveModel.get()
      modelData[@data.fieldName] = @connection.get()
      @data.reactiveModel.set modelData

commonRendered = -> ->
  attrs = _.omit @data, ["connection"]
  for key, val of attrs
    $(@firstNode).attr key, val

commonHelpers = ->
  isEditMode: -> Template.instance().editMode.get()
  connectionValue: ->
    Template.instance().connection.get()

commonEvents = ->
  "input *, change input[type='checkbox'], autocompleteselect *": ( ev, tpl ) -> _.defer =>
    node = $ ev.currentTarget
    val = if tpl.data.type is "checkbox" then node.is(":checked") else node.val()
    if tpl.data.type isnt "select" then node.attr "size", val.length or 2
    tpl.connection.set val

  "click span": ( ev, tpl ) ->
    Template.instance().editMode.set true
    _.defer ->
      node = tpl.$ "input, select"
      val = node.val()
      node.attr "size", val.length or 2
      node.focus()

  "blur *, keyup *": ( ev, tpl ) ->
    return unless ev.keyCode is 13 or not ev.keyCode
    return if $(ev.currentTarget).val?()?.trim?() is ""

    if Template.instance().data.isEditable
      tpl = Template.instance()
      setTimeout -> tpl.editMode.set false
      , 100

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
