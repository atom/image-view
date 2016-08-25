path = require 'path'
fs = require 'fs-plus'
{Emitter, File, CompositeDisposable} = require 'atom'

# Editor model for an image file
module.exports =
class ImageEditor
  atom.deserializers.add(this)

  @deserialize: ({filePath}) ->
    if fs.isFileSync(filePath)
      new ImageEditor(filePath)
    else
      console.warn "Could not deserialize image editor for path '#{filePath}' because that file no longer exists"

  constructor: (filePath) ->
    @file = new File(filePath)
    @uri = "file://" + encodeURI(filePath.replace(/\\/g, '/')).replace(/#/g, '%23').replace(/\?/g, '%3F')
    @subscriptions = new CompositeDisposable()
    @emitter = new Emitter

  serialize: ->
    {filePath: @getPath(), deserializer: @constructor.name}

  getViewClass: ->
    require './image-editor-view'

  terminatePendingState: ->
    @emitter.emit 'did-terminate-pending-state' if this.isEqual(atom.workspace.getActivePane().getPendingItem())

  onDidTerminatePendingState: (callback) ->
    @emitter.on 'did-terminate-pending-state', callback

  # Register a callback for when the image file changes
  onDidChange: (callback) ->
    changeSubscription = @file.onDidChange(callback)
    @subscriptions.add(changeSubscription)
    changeSubscription

  # Register a callback for whne the image's title changes
  onDidChangeTitle: (callback) ->
    renameSubscription = @file.onDidRename(callback)
    @subscriptions.add(renameSubscription)
    renameSubscription

  destroy: ->
    @subscriptions.dispose()

  # Retrieves the filename of the open file.
  #
  # This is `'untitled'` if the file is new and not saved to the disk.
  #
  # Returns a {String}.
  getTitle: ->
    if filePath = @getPath()
      path.basename(filePath)
    else
      'untitled'

  # Retrieves the URI of the image.
  #
  # Returns a {String}.
  getURI: -> @uri

  # Retrieves the absolute path to the image.
  #
  # Returns a {String} path.
  getPath: -> @file.getPath()

  # Compares two {ImageEditor}s to determine equality.
  #
  # Equality is based on the condition that the two URIs are the same.
  #
  # Returns a {Boolean}.
  isEqual: (other) ->
    other instanceof ImageEditor and @getURI() is other.getURI()

  # Essential: Invoke the given callback when the editor is destroyed.
  #
  # * `callback` {Function} to be called when the editor is destroyed.
  #
  # Returns a {Disposable} on which `.dispose()` can be called to unsubscribe.
  onDidDestroy: (callback) ->
    @emitter.on 'did-destroy', callback
