{$, View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'
ImageEditor = require './image-editor'
bytes = require 'bytes'

module.exports =
class ImageEditorStatusView extends View
  @content: ->
    @div class: 'status-image inline-block', =>
      @span class: 'image-size', outlet: 'imageSizeStatus'

  initialize: (@statusBar) ->
    @disposables = new CompositeDisposable
    @attach()

    @disposables.add atom.workspace.onDidChangeActivePaneItem => @updateImageSize()

  attach: ->
    @statusBar.addLeftTile(item: this)

  attached: ->
    @updateImageSize()

  getImageSize: ({originalHeight, originalWidth, imageSize}) ->
    @imageSizeStatus.text("#{originalWidth}x#{originalHeight} #{bytes(imageSize)}").show()

  updateImageSize: ->
    @imageLoadDisposable?.dispose()

    editor = atom.workspace.getActivePaneItem()
    if editor instanceof ImageEditor
      @editorView = $(atom.views.getView(editor)).view()
      @getImageSize(@editorView) if @editorView.loaded
      @imageLoadDisposable = @editorView.onDidLoad =>
        if editor is atom.workspace.getActivePaneItem()
          @getImageSize(@editorView)
    else
      @imageSizeStatus.hide()
