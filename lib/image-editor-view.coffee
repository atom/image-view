_ = require 'underscore-plus'
path = require 'path'
{$, ScrollView} = require 'atom-space-pen-views'
{Emitter, CompositeDisposable} = require 'atom'

# View that renders the image of an {ImageEditor}.
module.exports =
class ImageEditorView extends ScrollView
  @content: ->
    @div class: 'image-view', tabindex: -1, =>
      @div class: 'image-controls', outlet: 'imageControls', =>
        @a outlet: 'whiteTransparentBackgroundButton', class: 'image-controls-color-white', value: '#fff', =>
          @text 'white'
        @a outlet: 'blackTransparentBackgroundButton', class: 'image-controls-color-black', value: '#000', =>
          @text 'black'
      @div class: 'image-container', =>
        @div class: 'image-container-cell', =>
          @img outlet: 'image'

  initialize: (@editor) ->
    super
    @emitter = new Emitter

  attached: ->
    @disposables = new CompositeDisposable

    @loaded = false
    @image.hide()
    @updateImageUri()

    @disposables.add @editor.onDidChange => @updateImageUri()
    @disposables.add atom.commands.add @element,
      'image-view:reload': => @updateImageUri()
      'image-view:zoom-in': => @zoomIn()
      'image-view:zoom-out': => @zoomOut()
      'image-view:reset-zoom': => @resetZoom()

    @image.load =>
      @originalHeight = @image.height()
      @originalWidth = @image.width()
      @loaded = true
      @image.show()
      @emitter.emit 'did-load'

    @disposables.add atom.tooltips.add @whiteTransparentBackgroundButton[0], title: "Use white transparent background"
    @disposables.add atom.tooltips.add @blackTransparentBackgroundButton[0], title: "Use black transparent background"

    if pane = @getPane()
      @imageControls.find('a').on 'click', (e) =>
        @changeBackground $(e.target).attr 'value'

      # Hide controls for jpg and jpeg images as they don't have transparency
      if path.extname(@editor.getPath()).toLowerCase() in ['.jpg', '.jpeg']
        @imageControls.hide()

  onDidLoad: (callback) ->
    @emitter.on 'did-load', callback

  detached: ->
    @disposables.dispose()

  updateImageUri: ->
    @image.attr('src', "#{@editor.getUri()}?time=#{Date.now()}")

  # Retrieves this view's pane.
  #
  # Returns a {Pane}.
  getPane: ->
    @parents('.pane').view()

  # Zooms the image out by 10%.
  zoomOut: ->
    @adjustSize(0.9)

  # Zooms the image in by 10%.
  zoomIn: ->
    @adjustSize(1.1)

  # Zooms the image to its normal width and height.
  resetZoom: ->
    return unless @loaded and @isVisible()

    @image.width(@originalWidth)
    @image.height(@originalHeight)

  # Adjust the size of the image by the given multiplying factor.
  #
  # factor - A {Number} to multiply against the current size.
  adjustSize: (factor) ->
    return unless @loaded and @isVisible()

    newWidth = @image.width() * factor
    newHeight = @image.height() * factor
    @image.width(newWidth)
    @image.height(newHeight)

  # Changes the background color of the image view.
  #
  # color - A {String} that is a valid CSS hex color.
  changeBackground: (color) ->
    return unless @loaded and @isVisible() and color
    # TODO: in the future, probably validate the color
    @image.css 'background-color', color
