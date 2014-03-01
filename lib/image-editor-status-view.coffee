{View} = require 'atom'
ImageEditor = require './image-editor'

module.exports =
class ImageEditorStatusView extends View
  @content: ->
    @div class: 'status-image inline-block', =>
      @span class: 'image-size', outlet: 'imageSizeStatus'

  initialize: (filePath, image) =>
    @filePath = filePath
    @image = image
    if @filePath and @image
      @attach()

      @subscribe atom.workspaceView, 'pane-container:active-pane-item-changed', =>
        editor = atom.workspaceView.getActivePaneItem()
        if editor instanceof ImageEditor and @filePath is editor.filePath
          @imageSizeStatus.parent().show()
        else
          @imageSizeStatus.parent().hide()

  attach: =>
    statusBar = atom.workspaceView.statusBar
    if statusBar
      statusBar.appendLeft this
      @getImageSize()

  getImageSize: =>
    imageWidth = @image.width()
    imageHeight = @image.height()
    @imageSizeStatus.text("#{imageWidth} px x #{imageHeight} px").show()
