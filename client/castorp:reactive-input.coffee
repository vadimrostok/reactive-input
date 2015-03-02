Template.reactiveInput.rendered = ->
  template = switch @data.input
    when "textarea" then Template.reactiveInputTextarea
    when "select" then Template.reactiveInputSelect
    else Template.reactiveInputInput
  templateData = _.omit @data, ["input"]

  Blaze.renderWithData template, templateData, @firstNode

formsCreated = -> ->
  @connection = @data.connection

formsRendered = -> ->
  $(@firstNode).attr "type", @data.input

  attrs = _.omit @data, ["connection"]
  for key, val of attrs
    $(@firstNode).attr key, val

formsHelpers = ->
  connecionValue: -> Template.instance().connection.get()

formsEvents = ->
  "input *": ( ev, tpl ) ->
    tpl.connection.set $(ev.currentTarget).val()

Template.reactiveInputInput.created = formsCreated()
Template.reactiveInputInput.rendered = formsRendered()
Template.reactiveInputInput.helpers formsHelpers()
Template.reactiveInputInput.events formsEvents()

Template.reactiveInputSelect.created = formsCreated()
Template.reactiveInputSelect.rendered = formsRendered()
Template.reactiveInputSelect.helpers _.extend formsHelpers(),
  selected: ( value ) ->
    if "#{value}" is "#{Template.instance().connection.get()}"
      "selected"
    else ""

Template.reactiveInputSelect.events formsEvents()

Template.reactiveInputTextarea.created = formsCreated()
Template.reactiveInputTextarea.rendered = formsRendered()
Template.reactiveInputTextarea.helpers formsHelpers()
Template.reactiveInputTextarea.events formsEvents()
