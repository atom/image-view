_ = require 'underscore-plus'
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

  # Register a callback for when the image's title changes
  onDidChangeTitle: (callback) ->
    renameSubscription = @file.onDidRename(callback)
    @subscriptions.add(renameSubscription)
    renameSubscription

  destroy: ->
    @subscriptions.dispose()

  # Essential: Retireves all {ImageEditor}s in the workspace.
  #
  # Returns an {Array} of {ImageEditor}s.
  getImageEditors: ->
    atom.workspace.getPaneItems().filter (item) -> item instanceof ImageEditor

  # Essential: Get the {ImageEditor}s title for display in other parts
  # of the UI such as tabs.
  #
  # This is `'untitled'` if the image not saved to the disk.
  #
  # Returns a {String}.
  getTitle: ->
    @getFileName() ? 'untitled'

  # Essential: Get unique title for display in other parts of the UI, such as
  # the window title.
  #
  # If the image is not saved to disk its title is "untitled"
  # If the image is saved, its unique title is formatted as one
  # of the following,
  # * "<filename>" when it is the only existing {ImageEditor} with this file name.
  # * "<filename> — <unique-dir-prefix>" when other {ImageEditors} have this file name.
  #
  # Returns a {String}
  getLongTitle: ->
    if @getPath()
      fileName = @getFileName()

      allPathSegments = []
      for imageEditor in @getImageEditors() when imageEditor isnt this
        if imageEditor.getFileName() is fileName
          allPathSegments.push(imageEditor.getDirectoryPath().split(path.sep))

      if allPathSegments.length is 0
        return fileName

      ourPathSegments = @getDirectoryPath().split(path.sep)
      allPathSegments.push ourPathSegments

      loop
        firstSegment = ourPathSegments[0]

        commonBase = _.all(allPathSegments, (pathSegments) -> pathSegments.length > 1 and pathSegments[0] is firstSegment)
        if commonBase
          pathSegments.shift() for pathSegments in allPathSegments
        else
          break

      "#{fileName} \u2014 #{path.join(pathSegments...)}"
    else
      'untitled'

  getFileName: ->
    if filePath = @getPath()
      path.basename(filePath)
    else
      null

  getDirectoryPath: ->
    if fullPath = @getPath()
      path.dirname(fullPath)
    else
      null

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
