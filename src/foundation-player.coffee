# foundation-player.js
# Author: Alexander Egorov

# Basic usage:
# $('.foundation-player').foundationPlayer
#    playOnStart: false
# or:
# $('.foundation-player').foundationPlayer('seekToTime', 'Hello, world');
# $('.foundation-player').foundationPlayer('seek', '1:50');
#
# TODO:
# 1) Player width calculation
# 2) Shut others when it statrs
# 3) Loading indicator
(($, window) ->
  # Define the plugin class
  class FoundationPlayer
    defaults:
      size: 'normal'        # Size of player. Internall it is just class name
      # Look and feel options
      playOnStart: true     # play as soon as it's loaded
      # Waveform options
      showWave: true        # Show waveform

    constructor: (el, options) ->
      @options = $.extend({}, @defaults, options)
      @wavesurfer = Object.create WaveSurfer
      # Elements
      @$el = $(el)
      # Calls
      @init()

    # Additional plugin methods go here
    init: ->
      # Init function
      # Setup range slider
      setUpClass(@$el, this.options)
      return unless checkOptions(this.options)
      setUpRangeSlider(@$el)
      setUpWaveSurfer(this)
      window.wtf = this

    seekToTime: (time) -> # Just a dummy place holder
      # @$el.html(@options.paramA + ': ' + echo)
      return
    play: ->
      return
  # Define the plugin
    setUpRangeSlider = (element) ->
      return
    setUpWaveSurfer = (e) ->
      e.wavesurfer.init
        # Customizable stuff
        # - e.options.showWave

        # Opiniated defaults for WaveSurfer
        container: e.$el[0] # First guy...
        # Please create an issue if need need something to customize
        waveColor: '#EEEEEE'
        progressColor: '#DDDDDD'
        cursorColor: 'transparent' # bug with hideScrollbar: true?
        # hideScrollbar: true
        height: 96
        barWidth: 1
        # normalize: true # no idea what is that
        # interact: false
        skipLength: 15
      # Set 'ready' callback
      if e.options.playOnStart
        e.wavesurfer.on 'ready', ->
          e.wavesurfer.play() # play() must be called in callback
      # Perform load
      e.wavesurfer.load e.options.loadURL
      return
    # Setup default class
    setUpClass = (e,o) ->
      e.addClass(o.size)
    # Check passed options:
    # 1. Ensure loadURL is present
    checkOptions = (o) ->
      if o.loadURL
        return true
      else
        console.error 'Please specify `loadURL`. It has no default setings.'
        return false
  # jQuery extend part
  $.fn.extend foundationPlayer: (option, args...) ->
    # Set up FoundationPlayers for documant
    if !$.data(document.body, 'FoundationPlayers')
      $.data(document.body, 'FoundationPlayers', [] )
    @each ->
      if !$.data(this, 'FoundationPlayer')
        fplayer = new FoundationPlayer(this, option)
        $.data this, 'FoundationPlayer', fplayer
        $.data(document.body, 'FoundationPlayers').push(fplayer)
) window.jQuery, window
