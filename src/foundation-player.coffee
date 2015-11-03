# foundation-player.js
# Author: Alexander Egorov

# Usage:
# $('.foundation-player').foundationPlayer
#    playOnStart: false
# or:
#    $('.foundation-player').foundationPlayer('seekToTime', 'Hello, world');
#    $('.foundation-player').foundationPlayer('seek', '1:50');

# Some conventions:
# - Most of buttons has selector `.player-button.play em` where:
#   `.player-button.play` is li element
#   `em` is actual event target

# TODO:
# 1) Player width calculation
# 2) Shut others when it statrs
# 3) Smart redraw of Waveform
#   wavesurfer.params.height = (waveformFrame.offsetHeight - 30); //30px is the time code height, may different in your environment
#   wavesurfer.drawer.setHeight((waveformFrame.offsetHeight - 30));
#   wavesurfer.drawBuffer();

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
      @muted = false # by default player isn't muted
      # Elements
      @$el = $(el)
      # Calls
      @init()

    # Additional plugin methods go here
    init: ->
      # Init function
      return unless checkOptions(this.options) # Check passed options
      setUpClassAndStyle(@$el, this.options) # Setup default class

      # Player setup
      setUpWaveSurfer(this) # WaveSurfer setup
      setUpButtonPlayPause(this) # Set up Play/Pause
      setUpButtonVolume(this) # Set up Play/Pause

      # Todooo...
      setUpRangeSlider(this) # Setup range slider

    seekToTime: (time) -> # Just a dummy place holder
      # @$el.html(@options.paramA + ': ' + echo)
      return
    play: ->
      return

    # WaveSurfer setup
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
    setUpClassAndStyle = (e,o) ->
      e.addClass(o.size)
      return e

    # Set up Play/Pause
    setUpButtonPlayPause = (e) ->
      button = e.$el.find('.player-button.play em')
      button.on 'click', e, ->
        e.wavesurfer.playPause() # Play or pause
        if e.wavesurfer.isPlaying() # Update button class
          swithClass this, 'fi-play', 'fi-pause'
        else
          swithClass this, 'fi-pause', 'fi-play'
      return e

    # Set up Play/Pause
    setUpButtonVolume = (e) ->
      button = e.$el.find('.player-button.volume em')
      button.on 'click', e, ->
        if e.muted
          e.muted = false
          e.wavesurfer.toggleMute()
          swithClass this, 'fi-volume', 'fi-volume-strike'
        else
          e.muted = true
          e.wavesurfer.toggleMute()
          swithClass this, 'fi-volume-strike', 'fi-volume'
      return e

    # Setup range slider
    setUpRangeSlider = (e) ->
      # From Slider to Player
      # $('[data-slider]').on 'change.fndtn.slider', -> 1

      # From Player to Slider
      # $('.range-slider').foundation 'slider', 'set_value', new_value;

      # Reflow
      # $(document).foundation('slider', 'reflow');

    # Check passed options
    # 1. Ensure loadURL is present
    checkOptions = (o) ->
      if o.loadURL
        return true
      else
        console.error 'Please specify `loadURL`. It has no default setings.'
        return false
    # Some relly internal stuff goes here
    #
    swithClass = (e, from, to) ->
      $(e).addClass(from).removeClass(to)

  # Define the jQuery plugin
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
