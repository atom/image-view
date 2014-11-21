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
    @unsubscribe(@editorView) if @editorView?

    editor = atom.workspace.getActivePaneItem()
    if editor instanceof ImageEditor
      @editorView = atom.workspaceView.getActiveView()
      @getImageSize(@editorView) if @editorView.loaded
      @subscribe @editorView, 'image-view:loaded', =>
        if @editorView is atom.workspaceView.getActiveView()
          @getImageSize(@editorView)
    else
      @imageSizeStatus.hide()
