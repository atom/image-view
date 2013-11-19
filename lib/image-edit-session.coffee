path = require 'path'
{_, Document, fs} = require 'atom'

# Public: Manages the states between {Editor}s, images, and the project as a whole.
#
# Essentially, the graphical version of a {EditSession}.
module.exports=
class ImageEditSession
  @acceptsDocuments: true
  atom.deserializers.add(this)
  @version: 1

  @activate: ->
    # Files with these extensions will be opened as images
    imageExtensions = ['.gif', '.jpeg', '.jpg', '.png']
    atom.project.registerOpener (filePath) ->
      if _.include(imageExtensions, path.extname(filePath))
        new ImageEditSession(path: filePath)

  @deserialize: (state) ->
    relativePath = state.get('relativePath')
    resolvedPath = atom.project.resolve(relativePath) if relativePath
    if fs.isFileSync(resolvedPath)
      new ImageEditSession(state)
    else
      console.warn "Could not build image edit session for path '#{relativePath}' because that file no longer exists"

  constructor: (optionsOrState) ->
    if optionsOrState instanceof Document
      @state = optionsOrState
      @path = atom.project.resolve(@getRelativePath())
    else
      {@path} = optionsOrState
      @state = atom.site.createDocument
        deserializer: @constructor.name
        version: @constructor.version
        relativePath: atom.project.relativize(@path)

  serialize: -> @state.clone()

  getState: -> @state

  getViewClass: ->
    require './image-view'

  ### Public ###

  # Retrieves the filename of the open file.
  #
  # This is `'untitled'` if the file is new and not saved to the disk.
  #
  # Returns a {String}.
  getTitle: ->
    if sessionPath = @getPath()
      path.basename(sessionPath)
    else
      'untitled'

  # Retrieves the URI of the current image.
  #
  # Returns a {String}.
  getUri: -> @getRelativePath()

  getRelativePath: -> @state.get('relativePath')

  # Retrieves the path of the current image.
  #
  # Returns a {String}.
  getPath: -> @path

  # Compares two `ImageEditSession`s to determine equality.
  #
  # Equality is based on the condition that the two URIs are the same.
  #
  # Returns a {Boolean}.
  isEqual: (other) ->
    other instanceof ImageEditSession and @getUri() is other.getUri()
