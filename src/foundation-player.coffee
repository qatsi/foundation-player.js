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
# 5) Fix Safari quirks for buttons hover state
# 6) Fixed buttons sizes to prefent overflow in hover state
# 7) API Method to navigate to timestamp e.g. '02:10'
# 8) API Change size method

# Nice to or *must* have:
# 1) Highlight table of contents on progress bar e.g. dots or bars
# 2) Ability to manage many <audio> elements via playlist
# 3) Check is it possible to get meta information from audio
# 4) Buffering option for playlist items and single media-file
# 5) Next/Previous buttons when necessary
# 6) Buffering status aka. load indicator
# 7) Mobile actions like touch and etc.
# 8) Mobile "first" :-(
# 9) Show meta information when possible

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
      # Elements
      @$wrapper = $(el)
      @$player = @$wrapper.children('.player')
      @audio = @$wrapper.children('audio').get(0)
      @$play = @$wrapper.find('.player-button.play em')
      @$rewind = @$wrapper.find('.player-button.rewind em')
      @$volume = @$wrapper.find('.player-button.volume em')
      @$elapsed = @$wrapper.find('.player-status.time .elapsed')
      @$remains = @$wrapper.find('.player-status.time .remains')
      # State
      @timer = null
      # Calls
      @init()

    # Additional plugin methods go here
    init: ->
      # Init function
      @setUpClassAndStyle()    # Setup default class
      # Player setup
      @setUpButtonPlayPause() # Set up Play/Pause
      @setUpButtonVolume()    # Set up volume button
      @setUpButtonRewind()    # Set up rewind button
      @updateTimeStatuses()   # Update both time statuses
      @setUpMainLoop()

    # Main loop
    setUpMainLoop: ->
      @timer = setInterval @playerLoopFunctions.bind(@), 100
    playerLoopFunctions: ->
      @updateButtonPlay() # XXX Only when stopped?
      @updateTimeStatuses()

    # TODO: seekToTime()
    seekToTime: (time) -> # Just a dummy place holder
      # @$wrapper.html(@options.paramA + ': ' + echo)
      return

    playPause: ->
      if @audio.paused # Update button class
        @audio.play()
      else
        @audio.pause()
      @updateButtonPlay()

    # XXX @wavesurfer
    # UI =======================================================================
    # Setup default class
    setUpClassAndStyle: ->
      @$wrapper.addClass(@options.size)

      # Calculate player width
      # XXX Added initial extra due to 2px error...
      # TODO Refactor to smaller function and call it on window resize :-(
      actualWidth = @$player.width()
      playerWidth = 0
      calculateChildrensWidth(@$player).each -> playerWidth += this
      @$player.width Math.floor(5 + playerWidth/actualWidth*100) + '%'
    # Buttons ==================================================================
    # Set up Play/Pause
    setUpButtonPlayPause: ->
      @$play.bind 'click', @, (e) ->
        e.data.playPause() # Play or pause
    # Update Play/Pause
    updateButtonPlay: ->
      if @audio.paused # Update button class
        swithClass @$play, 'fi-pause', 'fi-play'
      else
        swithClass @$play, 'fi-play', 'fi-pause'
    # Set up volume button
    setUpButtonVolume: ->
      @$volume.bind 'click', @, (e) ->
        e.data.wavesurfer.toggleMute() # Play or pause
        e.data.updateButtonVolume()
    # Update volume button
    updateButtonVolume: ->
      if @wavesurfer.isMuted
        swithClass @$volume, 'fi-volume-strike', 'fi-volume'
      else
        swithClass @$volume, 'fi-volume', 'fi-volume-strike'
    # Set up rewind button
    setUpButtonRewind: ->
      @$rewind.on 'click', @, (e) ->
        e.data.wavesurfer.skipBackward()
        # XXX Update progress bar
    # Status ===================================================================
    # Update all statuses
    # Gets updated in loop
    updateTimeStatuses: ->
      @updateStatusElapsed()
      @updateStatusRemains()
    updateStatusElapsed: -> # Update $elapsed time status
      @$elapsed.text prettyTime @audio.currentTime
    updateStatusRemains: -> # Update $remains time status
      @$remains.text '-' + prettyTime @audio.duration-@audio.currentTime

    # Helpers ==================================================================
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
