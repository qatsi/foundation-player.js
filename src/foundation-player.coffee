# foundation-player.js
# Author: Alexander Egorov

# Usage:
# $('.foundation-player').foundationPlayer()

# Some conventions:
# - Buttons has selector `.player-button.play em` where:
#   `.player-button.play` is li element and `em` is event target
# - Status elements has selector `.player-status.time .elapsed` where:
#   `.player-status.time` is li element and `.elapsed` is target to update

# TODO:
# - Shut others when it statrs
# - Loading indicator
# - Fix Safari quirks for buttons hover state
# - API Method to navigate to timestamp e.g. '02:10'
# - Set up window resize handler for player
# - aN:aN in statuses while loading...

# Unsorted list of *nice to* or *must* have:
# - Pressed state for buttons
# - Highlight table of contents on progress bar e.g. dots or bars
# - Ability to manage many <audio> elements via playlist
# - Check is it possible to get meta information from audio
# - Buffering option for playlist items and single media-file
# - Next/Previous buttons when necessary
# - Buffering status aka load indicator
# - Mobile actions like touch and etc.
# - Mobile "first" :-(
# - Show meta information when possible
# - Error handling

(($, window) ->
  # Define the plugin class
  class FoundationPlayer
    defaults:
      size: 'normal'        # Size of player <normal|small>
      # Look and feel options
      playOnStart: true     # TODO: play as soon as it's loaded
      skipSeconds: 10       # how many we want to skip
      # Volume options
      dimmedVolume: 0.25
      # Animation Duration
      animate: false
      quick: 50
      moderate: 150

    constructor: (el, opt) ->
      @options = $.extend({}, @defaults, opt)
      # Elements
      @$wrapper =  $(el)
      @$player =   @$wrapper.children('.player')
      @$play =     @$wrapper.find('.player-button.play em')
      @$rewind =   @$wrapper.find('.player-button.rewind em')
      @$volume =   @$wrapper.find('.player-button.volume em')
      @$elapsed =  @$wrapper.find('.player-status.time .elapsed')
      @$remains =  @$wrapper.find('.player-status.time .remains')
      @$progress = @$wrapper.find('.player-progress .progress')
      @$played =   @$progress.find('.meter')
      @$loaded =   @$played.clone().appendTo(@$progress)
      @audio =     @$wrapper.children('audio').get(0)
      # State
      @timer =     null
      @played =    0
      @nowdragging = false
      @currentPlayerSize = @options.size
      # Calls
      @initialize()

    # Additional plugin methods go here
    initialize: ->
      # Init function
      @resetClassAndStyle()   # Setup classes and styles
      # Player setup
      @setUpButtonPlayPause() # Set up Play/Pause
      @setUpButtonVolume()    # Set up volume button
      @setUpButtonRewind()    # Set up rewind button
      @setUpPlayedProgress()  # Set up played progress meter
      @updateTimeStatuses()   # Update both time statuses
      @setUpMainLoop()        # Fire up main loop

    # Main loop
    setUpMainLoop: ->
      @timer = setInterval @playerLoopFunctions.bind(@), 500
    playerLoopFunctions: ->
      @updateButtonPlay() # XXX Only when stopped?
      @updateTimeStatuses()
      @updatePlayedProgress()
    # TODO: seekToTime()
    # Playback =================================================================
    playPause: ->
      if @audio.paused # Update button class
        @audio.play()
      else
        @audio.pause()
      @updateButtonPlay()
      @
    play: ->
      @audio.play()
      @updateButtonPlay()
      @
    pause: ->
      @audio.pause()
      @updateButtonPlay()
      @

    seekToTime: (time) ->
      # Numeric e.g. 42th second
      if isNumber(time)
        @audio.currentTime = forceRange time, @audio.duration
      # String e.g. '15', '42'...
      else if m = time.match /^(\d{0,3})$/
        @audio.currentTime = forceRange m[1], @audio.duration
      # String e.g. '00:15', '1:42'...
      else if m = time.match /^(\d?\d):(\d\d)$/
        time = (parseInt m[1], 10) * 60 + (parseInt m[2], 10)
        @audio.currentTime = forceRange time, @audio.duration
      else
        console.error "seekToTime(time), invalid argument: #{time}"
      # Common part, update UI and return
      @updatePlayedProgress()
      @updateTimeStatuses()
      @

    seekPercent: (p) ->
      # Can use both 0.65 and 65
      @audio.currentTime = @audio.duration * (if p >= 1 then p/100 else p)
      @updatePlayedProgress()
      @updateTimeStatuses()
      @

    # Generic ==================================================================
    # Setup default class
    resetClassAndStyle: ->
      # Set initial size
      @$wrapper.addClass(@options.size)
      # Calculate player width
      @setPlayerSizeHandler()
      # TODO: Setup styles for meter clone @$loaded
      # - position: absolute; height: 9px; opacity: 0.5;

    # Buttons ==================================================================
    # Set up Play/Pause
    setUpButtonPlayPause: ->
      @$play.bind 'click', () =>
        @playPause() # Play or pause
    # Update Play/Pause
    updateButtonPlay: ->
      if @audio.paused # Update button class
        switchClass @$play, 'fi-pause', 'fi-play'
      else
        switchClass @$play, 'fi-play', 'fi-pause'
    # Set up volume button
    setUpButtonVolume: ->
      @$volume.bind 'click', () =>
        @toggleMute()
        @updateButtonVolume()
    # Update volume button
    updateButtonVolume: ->
      if @audio.muted
        switchClass @$volume, 'fi-volume-strike', 'fi-volume'
      else
        switchClass @$volume, 'fi-volume', 'fi-volume-strike'
    # Set up rewind button
    setUpButtonRewind: ->
      @$rewind.on 'click', () =>
        @seekToTime(@audio.currentTime - @options.skipSeconds)

    # Progress =================================================================
    setUpPlayedProgress: ->
      @$played.css 'width', @played + '%'
      # Click and drag progress
      @$progress.on 'click.fndtn.player', (e) =>
        @seekPercent(Math.floor e.offsetX / @$progress.outerWidth() * 100)
      # Drag section is tricky
      # TODO: Mobile actions
      # TODO: DRYup this code
      @$progress.on 'mousedown.fndtn.player',  () =>
        @nowdragging = true
        @setVolume(@options.dimmedVolume)
      $(document).on 'mouseup.fndtn.player', () =>
        if @nowdragging
          @nowdragging = false
          @setVolume(1)
      @$progress.on 'mouseup.fndtn.player', () =>
        if @nowdragging
          @nowdragging = false
          @setVolume(1)
      @$progress.on 'mousemove.fndtn.player', (e) =>
        if @nowdragging
          @seekPercent(Math.floor e.offsetX / @$progress.outerWidth() * 100)
    updatePlayedProgress: ->
      @played = Math.round @audio.currentTime / @audio.duration * 100
      # Animate property if necessary
      if @options.animate
        @$played.animate width: @played + '%',
          (queue: false, duration: @options.quick)
      else
        @$played.css 'width', @played + '%'

    # Volume ===================================================================
    setVolume: (vol) ->
      # Animate property if necessary
      if @options.animate
        $(@audio).animate volume: vol, (duration: @options.moderate)
      else
        @audio.volume = vol
    toggleMute: ->
      @audio.muted = !@audio.muted
      @updateButtonVolume()

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

    # Look and feel ============================================================
    # This method toggles player size.
    # Method returns  size which was set i.e. 'small' or 'normal'
    togglePlayerSize: ->
      swithToSize = if @currentPlayerSize == 'normal' then 'small' else 'normal'
      @$wrapper.addClass(swithToSize).removeClass(@currentPlayerSize)
      @setPlayerSizeHandler()
      @currentPlayerSize = swithToSize
    # Set particalar player size
    setPlayerSize: (size) ->
      if ('normal' == size or 'small' == size) and size != @currentPlayerSize
          @$wrapper.addClass(size).removeClass(@currentPlayerSize)
          @setPlayerSizeHandler()
          @currentPlayerSize = size
      else
        console.error 'setPlayerSize: incorrect size argument'
        return false
    # Update player elemant width
    setPlayerSizeHandler: ->
      actualWidth = @$wrapper.width()
      magicNumber = 3
      playerWidth = 0
      calculateChildrensWidth(@$player).each -> playerWidth += this
      @$player.width Math.floor(magicNumber + playerWidth/actualWidth*100) + '%'
      @playerBeautifyProgressBar()
      # Add this to window resize
    # Deuglification of round progress bar when it 0% width
    playerBeautifyProgressBar: ->
      if @$progress.hasClass('round')
        semiHeight = @$played.height()/2
        @$played.css 'padding', "0 #{semiHeight}px"
    # Helpers ==================================================================
    # Some relly internal stuff goes here
    switchClass = (element, p, n) ->
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

    # Check number http://stackoverflow.com/a/1280236/228067
    isNumber = (x) ->
      typeof x == 'number' and isFinite(x)

    # Small function to check if 0 >= number >= max
    forceRange = (x, max) ->
      return 0 if x < 0
      return max if x > max
      x

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
