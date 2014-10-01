path = require 'path'
_ = require 'underscore-plus'
ImageEditor = require './image-editor'

module.exports =
  activate: ->
    atom.workspace.registerOpener(openUri)
    atom.packages.once('activated', createImageStatusView)

  deactivate: ->
    atom.workspace.unregisterOpener(openUri)

createImageStatusView = ->
  {statusBar} = atom.workspaceView
  if statusBar?
    ImageEditorStatusView = require './image-editor-status-view'
    view = new ImageEditorStatusView(statusBar)
    view.attach()

# Files with these extensions will be opened as images
imageExtensions = ['.gif', '.ico', '.jpeg', '.jpg', '.png', '.webp']
openUri = (uriToOpen) ->
  uriExtension = path.extname(uriToOpen).toLowerCase()
  if _.include(imageExtensions, uriExtension)
    new ImageEditor(uriToOpen)
