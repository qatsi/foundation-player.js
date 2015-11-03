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
    checkOptions = (o) ->
      if o.loadURL
        return true
      else
        console.error 'Please specify `loadURL`. It has no default setings.'
        return false

  # jQuery extend part
  $.fn.extend foundationPlayer: (option, args...) ->
    @each ->
      $this = $(this)
      data = $this.data('foundationPlayer')
      # Check double instantiation here
      if !data
        $this.data 'foundationPlayer', (data = new FoundationPlayer(this, option))
      if typeof option == 'string'
        data[option].apply(data, args)

) window.jQuery, window
