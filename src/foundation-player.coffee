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
# 1) XXX Reflow bug: set position to slider, resize window : - (
# 2) Shut others when it statrs
# 3) Loading indicator
# 4) Smart redraw of Waveform
#   wavesurfer.params.height = (waveformFrame.offsetHeight - 30);
#   //30px is the time code height, may different in your environment
#   wavesurfer.drawer.setHeight((waveformFrame.offsetHeight - 30));
#   wavesurfer.drawBuffer();
# 5) Fix Safari quirks for buttons hover state
# 6) Fixed buttons sizes to prefent overflow in hover state
# 7) API Method to navigate to timestamp e.g. "02:10"
# 8) API Change size method

# Nice to have:
# 1) Highlight table of contents on wavaform e.g. dots or bars

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
      @$player =  @$el.children('ul')
      @$play = @$el.find('.player-button.play em')
      @$rewind =  @$el.find('.player-button.rewind em')
      @$volume =  @$el.find('.player-button.volume em')
      @$elapsed = @$el.find('.player-status.time .elapsed')
      @$remains = @$el.find('.player-status.time .remains')
      @$slider =  @$el.find('.player-sliderbar .range-slider')
      # State
      @playedPercentage = 0
      @sliderPosition = 0
      @timer = null
      # Calls
      @init()

    # Additional plugin methods go here
    init: ->
      # Init function
      return if !hasCorrectOptions(@options) # Check passed options
      @setUpClassAndStyle()    # Setup default class
      # Player setup
      @setUpWaveSurfer()      # WaveSurfer setup
      @setUpButtonPlayPause() # Set up Play/Pause
      @setUpButtonVolume()    # Set up volume button
      @setUpButtonRewind()    # Set up rewind button
      @setUpRangeSlider()     # Set up range slider
      @updateStatus()         # Update both time statuses
      @setUpMainLoop()

    # Main loop
    setUpMainLoop: ->
      @timer = setInterval @playerLoopFunctions.bind(@), 1000
    playerLoopFunctions: ->
      @updatePercentage()
      @updateStatus()
      @updateSliderPosition()

    # TODO: seekToTime()
    seekToTime: (time) -> # Just a dummy place holder
      # @$el.html(@options.paramA + ': ' + echo)
      return
    # TODO: play()
    play: ->
      return

    # XXX WaveSurfer setup
    setUpWaveSurfer: () ->
      @wavesurfer.init
        # Customizable stuff
        # Opiniated defaults for WaveSurfer
        container: @$el[0] # First guy...
        # Please create an issue if need need something to customize
        waveColor: '#EEEEEE'
        progressColor: '#DDDDDD'
        cursorColor: 'transparent' # bug with hideScrollbar: true?
        # hideScrollbar: true
        height: 96
        barWidth: 1
        skipLength: @options.skipSeconds
      # Perform load
      @wavesurfer.load @options.loadURL
      # Set 'ready' callback
      wavesurfer = @wavesurfer
      if @options.playOnStart
        # play() must be called as callback in local variable
        @wavesurfer.on 'ready', -> wavesurfer.play()
      return

    # Setup default class
    setUpClassAndStyle: () ->
      @$el.addClass(@options.size)

      # Calculate player width
      # XXX Added initial extra due to 2px error...
      # TODO Refactor to smaller function and call it on window resize :-(
      actualWidth = @$player.width()
      playerWidth = 0
      calculateChildrensWidth(@$player).each -> playerWidth += this
      @$player.width Math.floor(5 + playerWidth/actualWidth*100) + '%'

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
      @$rewind.on 'click', @, (e) ->
        e.data.wavesurfer.skipBackward()
        e.data.updateSlider()

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
    updateSlider: () ->
      @updatePercentage()
      @updateSliderPosition()
    updateSliderPosition: () ->
      # XXX Shit!
      # @$slider.foundation('slider', 'set_value', @playedPercentage);

    # Update @playedPercentage according played state
    updatePercentage: () ->
      w = @wavesurfer
      @playedPercentage = Math.floor (w.getCurrentTime()/w.getDuration())*100
    # Update @sliderPosition according slider position
    # This updates continiusly durig slider drag
    updateSliderPercentage: () ->
      @sliderPosition = @$slider.attr('data-slider')
      # @playedPercentage = Math.floor (w.getCurrentTime()/w.getDuration())*100
    # Setup range slider
    setUpRangeSlider: ->
      # XXX From Player to Slider: $('.slider').f... 'slider', 'set_value', 23;
      # TODO Reflow $(document).foundation('slider', 'reflow');
      @$slider.on 'change.fndtn.slider', (-> @updatePlayerPosition()).bind(@)
    # Seek to @sliderPosition
    updatePlayerPosition: ->
      @wavesurfer.seekTo @updateSliderPercentage()/100
      @updateStatus() # Status should be updated after seek

    # Check passed options
    hasCorrectOptions = (o) ->
      # 1. Ensure loadURL is present
      if o.loadURL
        return true
      else
        console.error 'Please specify `loadURL`. It has no default setings.'
        return false

    # Some relly internal stuff goes here
    swithClass = (element, p, n) ->
      $(element).addClass(p).removeClass(n)

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

    # Utility function to calculate actual withds of children elements
    calculateChildrensWidth = (e) ->
      e.children().map -> $(@).outerWidth(true) # Get widths including margin

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
