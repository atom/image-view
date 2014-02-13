path = require 'path'
_ = require 'underscore-plus'
ImageEditor = require './image-editor'

module.exports =
  activate: ->
    atom.workspace.registerOpener(openUri)

  deactivate: ->
    atom.workspace.unregisterOpener(openUri)

# Files with these extensions will be opened as images
imageExtensions = ['.gif', '.ico', '.jpeg', '.jpg', '.png']
openUri = (uriToOpen) ->
  uriExtension = path.extname(uriToOpen)
  if _.include(imageExtensions, uriExtension)
    new ImageEditor(uriToOpen)
