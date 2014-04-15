{View} = require 'atom'
ImageEditor = require './image-editor'

module.exports =
class ImageEditorStatusView extends View
  @content: ->
    @div class: 'status-image inline-block', =>
      @span class: 'image-size', outlet: 'imageSizeStatus'

  initialize: (@statusBar) ->
    @attach()

    @subscribe atom.workspaceView, 'pane-container:active-pane-item-changed', =>
      @updateImageSize()

  attach: ->
    @statusBar.appendLeft this

  afterAttach: ->
    @updateImageSize()

  getImageSize: ({originalHeight, originalWidth}) ->
    @imageSizeStatus.text("#{originalWidth}x#{originalHeight}").show()

  updateImageSize: ->
    editor = atom.workspace.getActivePaneItem()
    if editor instanceof ImageEditor
      view = atom.workspaceView.getActiveView()
      if view.loaded
        @getImageSize(view)
      else
        # Wait for image to load before getting originalWidth and originalHeight
        view.image.load =>
          # Make sure view is still active since load is async
          @getImageSize(view) if view is atom.workspaceView.getActiveView()
    else
      @imageSizeStatus.hide()
