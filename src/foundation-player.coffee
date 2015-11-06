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
# - Shut others when it statrs
# - Loading indicator
# - Fix Safari quirks for buttons hover state
# - Pressed state for buttons
# - API Method to navigate to timestamp e.g. '02:10'
# - API Change size method

# Nice to or *must* have:
# - Highlight table of contents on progress bar e.g. dots or bars
# - Ability to manage many <audio> elements via playlist
# - Check is it possible to get meta information from audio
# - Buffering option for playlist items and single media-file
# - Next/Previous buttons when necessary
# - Buffering status aka. load indicator
# - Mobile actions like touch and etc.
# - Mobile "first" :-(
# - Show meta information when possible

(($, window) ->
  # Define the plugin class
  class FoundationPlayer
    defaults:
      size: 'normal'        # Size of player. Internall it is just class name
      # Look and feel options
      playOnStart: true     # play as soon as it's loaded
      skipSeconds: 10       # how many we want to skip

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
      @$progress = @$wrapper.find('.player-progress .progress')
      @$played = @$progress.find('.meter')
      # State
      @timer = null
      @played = 0
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
      @setUpPlayedProgress()  # Set up played progress meter
      @updateTimeStatuses()   # Update both time statuses
      @setUpMainLoop()

    # Main loop
    setUpMainLoop: ->
      @timer = setInterval @playerLoopFunctions.bind(@), 200
    playerLoopFunctions: ->
      @updateButtonPlay() # XXX Only when stopped?
      @updateTimeStatuses()
      @updatePlayedProgress()
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

    # UI =======================================================================
    # Setup default class
    setUpClassAndStyle: ->
      @$wrapper.addClass(@options.size)
      # Calculate player width
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
        s = e.data
        s.audio.muted = !s.audio.muted
        s.updateButtonVolume()
    # Update volume button
    updateButtonVolume: ->
      if @audio.muted
        swithClass @$volume, 'fi-volume-strike', 'fi-volume'
      else
        swithClass @$volume, 'fi-volume', 'fi-volume-strike'
    # Set up rewind button
    setUpButtonRewind: ->
      @$rewind.on 'click', @, (e) ->
        s = e.data
        s.audio.currentTime = s.audio.currentTime - s.options.skipSeconds
        s.updatePlayedProgress()
        s.updateTimeStatuses()
    # Progress =================================================================
    setUpPlayedProgress: ->
      # Deuglification of round progress bar when it 0% width
      if @$progress.hasClass('round')
        semiHeight = @$played.height()/2
        @$played.css 'padding', "0 #{semiHeight}px"
      @$played.css 'width', @played + '%'
    updatePlayedProgress: ->
      @played = Math.round @audio.currentTime / @audio.duration * 100
      @$played.css 'width', @played + '%'
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
