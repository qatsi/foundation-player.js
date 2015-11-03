# foundation-player.js
# Author: Alexander Egorov

# Usage:
# $('.foundation-player').foundationPlayer
#    playOnStart: false
# or:
#    $('.foundation-player').foundationPlayer('seekToTime', 'Hello, world');
#    $('.foundation-player').foundationPlayer('seek', '1:50');

# Some conventions:
# - Buttons has selector `.player-button.play em` where:
#   `.player-button.play` is li element
#   `em` is actual event target
# - Status elements has selector `.player-status.time .elapsed` where:
#   `.player-status.time` is li element
#   `.elapsed` is actual target to update

# TODO:
# 1) Player width calculation
# 2) Shut others when it statrs
# 3) Loading indicator
# 4) Smart redraw of Waveform
#   wavesurfer.params.height = (waveformFrame.offsetHeight - 30);
#   //30px is the time code height, may different in your environment
#   wavesurfer.drawer.setHeight((waveformFrame.offsetHeight - 30));
#   wavesurfer.drawBuffer();
# 5) Fix Safari quirks for buttons hover state
# 6) Fixed buttons sizes to prefent overflow in hover state
# 7) Refactor this to @ : - (
# 8) Wavesurfer isMuted property

(($, window) ->
  # Define the plugin class
  class FoundationPlayer
    defaults:
      size: 'normal'        # Size of player. Internall it is just class name
      # Look and feel options
      playOnStart: true     # play as soon as it's loaded
      skipSeconds: 10       # how many we want to skip
      # Waveform options

    constructor: (el, options) ->
      @options = $.extend({}, @defaults, options)
      @wavesurfer = Object.create WaveSurfer
      # Elements
      @$el = $(el)
      @$play =  $(el).find('.player-button.play em')
      @$rewind =  $(el).find('.player-button.rewind em')
      @$volume =  $(el).find('.player-button.volume em')
      @$elapsed = $(el).find('.player-status.time .elapsed')
      @$remains = $(el).find('.player-status.time .remains')
      # Calls
      @init()

    # Additional plugin methods go here
    init: ->
      # Init function
      return unless checkOptions(this.options) # Check passed options
      setUpClassAndStyle(@$el, this.options) # Setup default class

      # Player setup
      setUpWaveSurfer(this) # WaveSurfer setup
      @setUpButtonPlayPause() # Set up Play/Pause
      @setUpButtonVolume()    # Set up volume button
      @setUpButtonRewind()    # Set up rewind button
      @updateStatus()         # Update both time statuses

      # Todooo...
      setUpRangeSlider(this) # Setup range slider
      return

    seekToTime: (time) -> # Just a dummy place holder
      # @$el.html(@options.paramA + ': ' + echo)
      return
    play: ->
      return

    # WaveSurfer setup
    setUpWaveSurfer = (e) ->
      e.wavesurfer.init
        # Customizable stuff
        # Opiniated defaults for WaveSurfer
        container: e.$el[0] # First guy...
        # Please create an issue if need need something to customize
        waveColor: '#EEEEEE'
        progressColor: '#DDDDDD'
        cursorColor: 'transparent' # bug with hideScrollbar: true?
        # hideScrollbar: true
        height: 96
        barWidth: 1
        skipLength: e.options.skipSeconds
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
    setUpButtonPlayPause: () ->
      @$play.bind 'click', @, (e) ->
        e.data.wavesurfer.playPause() # Play or pause
        e.data.updateButtonPlay()
    # Update Play/Pause
    updateButtonPlay: () ->
      if @wavesurfer.isPlaying() # Update button class
        swithClass @$play, 'fi-play', 'fi-pause'
      else
        swithClass @$play, 'fi-pause', 'fi-play'
      return @

    # Set up volume button
    setUpButtonVolume: () ->
      @$volume.bind 'click', @, (e) ->
        e.data.wavesurfer.toggleMute() # Play or pause
        e.data.updateButtonVolume()
    # Update volume button
    updateButtonVolume: () ->
      if @wavesurfer.isMuted
        swithClass @$volume, 'fi-volume-strike', 'fi-volume'
      else
        swithClass @$volume, 'fi-volume', 'fi-volume-strike'

    # Set up rewind button
    setUpButtonRewind: () ->
      @$rewind.on 'click', @wavesurfer, (e) -> e.data.skipBackward()

    # Update all statuses
    updateStatus: () ->
      @updateStatusElapsed()
      @updateStatusRemains()
    # Update $elapsed time status
    updateStatusElapsed: () ->
      @$elapsed.text prettyTime @wavesurfer.getCurrentTime()
    # Update $remains time status
    updateStatusRemains: () ->
      w = @wavesurfer
      @$remains.text '-' + prettyTime w.getDuration()-w.getCurrentTime()

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
    swithClass = (e, from, to) ->
      $(e).addClass(from).removeClass(to)

    # Foramt second to human readable format
    prettyTime = (s) ->
      # As seen here: http://stackoverflow.com/questions/3733227
      minutes = Math.floor s / 60
      seconds = Math.floor s - minutes * 60
      "#{stringPadLeft minutes, '0', 2}:#{stringPadLeft seconds, '0', 2}"

    # Small helper to padd time correctly
    stringPadLeft = (string,pad,length) ->
      # Quick and dirty
      # As seen here: http://stackoverflow.com/questions/3733227
      (new Array(length+1).join(pad)+string).slice(-length)

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
