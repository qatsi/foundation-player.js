# foundation-player.js
# Author: Alexander Egorov

(($, window) ->
  # Define the plugin class
  class FoundationPlayer
    defaults:
      size: 'normal'        # Size of player <normal|small>
      playOnLoad: false     # Play as soon as it's loaded
      skipSeconds: 10       # how many we want to skip
      dimmedVolume: 0.25
      animate: false
      quick: 50
      moderate: 150

    constructor: (el, opt) ->
      @options = $.extend({}, @defaults, opt)
      # jQuery Objects
      @$wrapper =  $(el)
      @$player =   @$wrapper.children('.player')
      @$play =     @$wrapper.find('.player-button.play em')
      @$rewind =   @$wrapper.find('.player-button.rewind em')
      @$volume =   @$wrapper.find('.player-button.volume em')
      @$elapsed =  @$wrapper.find('.player-status.time .elapsed')
      @$remains =  @$wrapper.find('.player-status.time .remains')
      @$progress = @$wrapper.find('.player-progress .progress')
      @$played =   @$progress.find('.meter.played')
      @$sources =  @$wrapper.children('audio')
      # DOM Elements
      # TODO: Manage current audio object more carefully
      @audio =     @$sources.get(0)
      # State
      @timer =     null
      @played =    0
      @nowdragging = false
      @currentPlayerSize = @options.size
      @canPlayCurrent = false
      # Calls
      @initialize()

    # Init function
    initialize: ->
      @resetClassAndStyle()   # Setup classes and styles
      @setUpCurrentAudio()    # Set up Play/Pause
      @setUpButtonPlayPause() # Set up Play/Pause
      @setUpButtonVolume()    # Set up volume button
      @setUpButtonRewind()    # Set up rewind button
      @setUpPlayedProgress()  # Set up played progress meter

    # Playback =================================================================
    playPause: ->
      if @audio.paused then @audio.play() else @audio.pause()
      @updateButtonPlay()
    play: ->
      @audio.play()
      @updateButtonPlay()
    pause: ->
      @audio.pause()
      @updateButtonPlay()

    seekToTime: (time) ->
      @audio.currentTime = (
        if isNumber(time) # Numeric e.g. 42th second
          time
        else if m = time.match /^(\d{0,3})$/  # String e.g. '15', '42'...
          m[1]
        else if m = time.match /^(\d?\d):(\d\d)$/ # String e.g. '00:15', '1:42'...
          (parseInt m[1], 10) * 60 + (parseInt m[2], 10)
        else
          console.error "seekToTime(time), invalid argument: #{time}"
      )
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

    # Setup current audio
    setUpCurrentAudio: ->
      @audio.preload = 'metadata' # Start preload of audio file
      $audio = $(@audio)
      $audio.on 'timeupdate.fndtn.player', () => # While playing
        @updatePlayedProgress()
        @updateTimeStatuses()
      # Bunch of <audio> events
      $audio.on 'loadstart.fndtn.player', () => # Loading is started
        @canPlayCurrent = false
        @updateDisabledStatus()
        @updateButtonPlay()
      $audio.on 'durationchange.fndtn.player', () => # "NaN" to loaded
        @updateTimeStatuses()   # Update both time statuses
      $audio.on 'progress.fndtn.player', () =>
        @redrawBufferizationBars()
      $audio.on 'canplay.fndtn.player', () => # Can be played
        @canPlayCurrent = true
        @play() if @options.playOnLoad
        @redrawBufferizationBars()
        @updateDisabledStatus()
        @updateButtonPlay()

    # Buttons ==================================================================
    # Set up Play/Pause
    setUpButtonPlayPause: ->
      @$play.bind 'click', () =>
        @playPause() if @canPlayCurrent
    # Update Play/Pause
    updateButtonPlay: ->
      @$play.toggleClass('fi-music', !@canPlayCurrent)
      @$play.toggleClass('fi-pause', @audio.paused && @canPlayCurrent)
      @$play.toggleClass('fi-play', !@audio.paused)
      @
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
      # Stop dragging common handler
      _stopDragHandler = () =>
        if @nowdragging
          @nowdragging = false
          @setVolume(1)
      $(document).on 'mouseup.fndtn.player', () -> _stopDragHandler()
      $(window).on 'mouseleave.fndtn.player', () -> _stopDragHandler()
      # Update player position
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
    redrawBufferizationBars: ->
      # This function should be called after playerBeautifyProgressBar
      # Remove all current indicators
      @$progress.find('.buffered').remove()
      segments = @audio.buffered.length
      # If there is at least one segment...
      if segments > 0
        # Some of $progress styles are used for buffer indicators
        t =  parseInt @$progress.css('padding-top'), 10
        l = parseInt @$progress.css('padding-left'), 10
        w = @$progress.width()
        h = @$progress.height()
        widthDelta = 2 * parseInt @$played.css('padding-left'), 10
        for range in [0...segments]
          b = @audio.buffered.start(range) # Segment start second
          e = @audio.buffered.end(range) # Segment end second
          switchClass(@$played.clone(), 'buffered', 'played')
          .css('left', l + (Math.floor w * (b / @audio.duration)) + 'px')
          .css('top', t).height(h).width(Math.floor(w*(e-b)/@audio.duration))
          .appendTo(@$progress)

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
    updateTimeStatuses: ->
      @updateStatusElapsed()
      @updateStatusRemains()
    updateStatusElapsed: -> # Update $elapsed time status
      @$elapsed.text prettyTime @audio.currentTime
    updateStatusRemains: -> # Update $remains time status
      @$remains.text '-' + prettyTime @audio.duration-@audio.currentTime
    updateDisabledStatus: -> # Update $remains time status
      @$player.toggleClass('disabled', !@canPlayCurrent)


    # Look and feel ============================================================
    # This method toggles player size
    togglePlayerSize: ->
      switchToSize = if @currentPlayerSize == 'normal' then 'small' else 'normal'
      switchClass @$wrapper, switchToSize, @currentPlayerSize
      @setPlayerSizeHandler()
      @redrawBufferizationBars()
      @currentPlayerSize = switchToSize
    # Set particalar player size
    setPlayerSize: (size) ->
      if ('normal' == size or 'small' == size) and size != @currentPlayerSize
          switchClass @$wrapper, size, @currentPlayerSize
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
        # TODO: Make it better
        @$played.css 'padding', "0 #{semiHeight}px"
        @$progress.find('.buffered').css 'padding', "0 #{semiHeight}px"
    # Helpers ==================================================================
    # Some really internal stuff goes here
    switchClass = (element, p, n) ->
      $(element).addClass(p).removeClass(n)

    # Format second to human readable format
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
