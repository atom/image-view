_ = require 'underscore-plus'
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

  updateImageSize: ->
    editor = atom.workspaceView.getActivePaneItem()
    if editor instanceof ImageEditor
      view = atom.workspaceView.getActiveView()
      if view.loaded
        imageWidth = view.originalWidth
        imageHeight = view.originalHeight
        @imageSizeStatus.text("#{imageWidth}px x #{imageHeight}px").show()
      else # wait for image to load before getting originalWidth and originalHeight
        view.image.load =>
          imageWidth = view.originalWidth
          imageHeight = view.originalHeight
          @imageSizeStatus.text("#{imageWidth}px x #{imageHeight}px").show()
    else
      @imageSizeStatus.hide()
