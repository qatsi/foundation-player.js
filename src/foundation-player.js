(function() {
  var slice = [].slice;

  (function($, window) {
    var FoundationPlayer;
    FoundationPlayer = (function() {
      var calculateChildrensWidth, prettyTime, stringPadLeft, swithClass;

      FoundationPlayer.prototype.defaults = {
        size: 'normal',
        playOnStart: true,
        skipSeconds: 10,
        dimmedVolume: 0.25,
        animate: false,
        quick: 50,
        moderate: 150
      };

      function FoundationPlayer(el, opt) {
        this.options = $.extend({}, this.defaults, opt);
        this.$wrapper = $(el);
        this.$player = this.$wrapper.children('.player');
        this.$play = this.$wrapper.find('.player-button.play em');
        this.$rewind = this.$wrapper.find('.player-button.rewind em');
        this.$volume = this.$wrapper.find('.player-button.volume em');
        this.$elapsed = this.$wrapper.find('.player-status.time .elapsed');
        this.$remains = this.$wrapper.find('.player-status.time .remains');
        this.$progress = this.$wrapper.find('.player-progress .progress');
        this.$played = this.$progress.find('.meter');
        this.$loaded = this.$played.clone().appendTo(this.$progress);
        this.audio = this.$wrapper.children('audio').get(0);
        this.timer = null;
        this.played = 0;
        this.nowdragging = false;
        this.currentPlayerSize = this.options.size;
        this.initialize();
      }

      FoundationPlayer.prototype.initialize = function() {
        this.resetClassAndStyle();
        this.setUpButtonPlayPause();
        this.setUpButtonVolume();
        this.setUpButtonRewind();
        this.setUpPlayedProgress();
        this.updateTimeStatuses();
        return this.setUpMainLoop();
      };

      FoundationPlayer.prototype.setUpMainLoop = function() {
        return this.timer = setInterval(this.playerLoopFunctions.bind(this), 500);
      };

      FoundationPlayer.prototype.playerLoopFunctions = function() {
        this.updateButtonPlay();
        this.updateTimeStatuses();
        return this.updatePlayedProgress();
      };

      FoundationPlayer.prototype.playPause = function() {
        if (this.audio.paused) {
          this.audio.play();
        } else {
          this.audio.pause();
        }
        this.updateButtonPlay();
        return !this.audio.paused;
      };

      FoundationPlayer.prototype.seekToTime = function(time) {};

      FoundationPlayer.prototype.seekPercent = function(p) {
        this.audio.currentTime = this.audio.duration * (p >= 1 ? p / 100 : void 0);
        this.updatePlayedProgress();
        return this.updateTimeStatuses();
      };

      FoundationPlayer.prototype.resetClassAndStyle = function() {
        this.$wrapper.addClass(this.options.size);
        return this.setPlayerSizeHandler();
      };

      FoundationPlayer.prototype.setUpButtonPlayPause = function() {
        return this.$play.bind('click', this, function(e) {
          return e.data.playPause();
        });
      };

      FoundationPlayer.prototype.updateButtonPlay = function() {
        if (this.audio.paused) {
          return swithClass(this.$play, 'fi-pause', 'fi-play');
        } else {
          return swithClass(this.$play, 'fi-play', 'fi-pause');
        }
      };

      FoundationPlayer.prototype.setUpButtonVolume = function() {
        return this.$volume.bind('click', this, function(e) {
          var s;
          s = e.data;
          s.toggleMute();
          return s.updateButtonVolume();
        });
      };

      FoundationPlayer.prototype.updateButtonVolume = function() {
        if (this.audio.muted) {
          return swithClass(this.$volume, 'fi-volume-strike', 'fi-volume');
        } else {
          return swithClass(this.$volume, 'fi-volume', 'fi-volume-strike');
        }
      };

      FoundationPlayer.prototype.setUpButtonRewind = function() {
        return this.$rewind.on('click', this, function(e) {
          var s;
          s = e.data;
          s.audio.currentTime = s.audio.currentTime - s.options.skipSeconds;
          s.updatePlayedProgress();
          return s.updateTimeStatuses();
        });
      };

      FoundationPlayer.prototype.setUpPlayedProgress = function() {
        this.$played.css('width', this.played + '%');
        this.$progress.on('click.fndtn.player', this, function(e) {
          return e.data.seekPercent(Math.floor(e.offsetX / $(this).outerWidth() * 100));
        });
        this.$progress.on('mousedown.fndtn.player', this, function(e) {
          e.data.nowdragging = true;
          return e.data.setVolume(e.data.options.dimmedVolume);
        });
        $(document).on('mouseup.fndtn.player', this, function(e) {
          if (e.data.nowdragging) {
            e.data.nowdragging = false;
            return e.data.setVolume(1);
          }
        });
        this.$progress.on('mouseup.fndtn.player', this, function(e) {
          if (e.data.nowdragging) {
            e.data.nowdragging = false;
            return e.data.setVolume(1);
          }
        });
        return this.$progress.on('mousemove.fndtn.player', this, function(e) {
          if (e.data.nowdragging) {
            return e.data.seekPercent(Math.floor(e.offsetX / $(this).outerWidth() * 100));
          }
        });
      };

      FoundationPlayer.prototype.updatePlayedProgress = function() {
        this.played = Math.round(this.audio.currentTime / this.audio.duration * 100);
        if (this.options.animate) {
          return this.$played.animate({
            width: this.played + '%'
          }, {
            queue: false,
            duration: this.options.quick
          });
        } else {
          return this.$played.css('width', this.played + '%');
        }
      };

      FoundationPlayer.prototype.setVolume = function(vol) {
        if (this.options.animate) {
          return $(this.audio).animate({
            volume: vol
          }, {
            duration: this.options.moderate
          });
        } else {
          return this.audio.volume = vol;
        }
      };

      FoundationPlayer.prototype.toggleMute = function() {
        this.audio.muted = !this.audio.muted;
        return this.updateButtonVolume();
      };

      FoundationPlayer.prototype.updateTimeStatuses = function() {
        this.updateStatusElapsed();
        return this.updateStatusRemains();
      };

      FoundationPlayer.prototype.updateStatusElapsed = function() {
        return this.$elapsed.text(prettyTime(this.audio.currentTime));
      };

      FoundationPlayer.prototype.updateStatusRemains = function() {
        return this.$remains.text('-' + prettyTime(this.audio.duration - this.audio.currentTime));
      };

      FoundationPlayer.prototype.togglePlayerSize = function() {
        var swithToSize;
        swithToSize = this.currentPlayerSize === 'normal' ? 'small' : 'normal';
        console.log("" + swithToSize);
        this.$wrapper.addClass(swithToSize).removeClass(this.currentPlayerSize);
        this.setPlayerSizeHandler();
        return this.currentPlayerSize = swithToSize;
      };

      FoundationPlayer.prototype.setPlayerSize = function(size) {
        if ('normal' === size || 'small' === size) {
          this.$wrapper.addClass(size).removeClass(this.currentPlayerSize);
          this.setPlayerSizeHandler();
          return this.currentPlayerSize = size;
        }
      };

      FoundationPlayer.prototype.setPlayerSizeHandler = function() {
        var actualWidth, magicNumber, playerWidth;
        actualWidth = this.$wrapper.width();
        magicNumber = 3;
        playerWidth = 0;
        calculateChildrensWidth(this.$player).each(function() {
          return playerWidth += this;
        });
        this.$player.width(Math.floor(magicNumber + playerWidth / actualWidth * 100) + '%');
        return this.playerBeautifyProgressBar();
      };

      FoundationPlayer.prototype.playerBeautifyProgressBar = function() {
        var semiHeight;
        if (this.$progress.hasClass('round')) {
          semiHeight = this.$played.height() / 2;
          return this.$played.css('padding', "0 " + semiHeight + "px");
        }
      };

      swithClass = function(element, p, n) {
        return $(element).addClass(p).removeClass(n);
      };

      prettyTime = function(s) {
        var minutes, seconds;
        minutes = Math.floor(s / 60);
        seconds = Math.floor(s - minutes * 60);
        return (stringPadLeft(minutes, '0', 2)) + ":" + (stringPadLeft(seconds, '0', 2));
      };

      stringPadLeft = function(string, pad, length) {
        return (new Array(length + 1).join(pad) + string).slice(-length);
      };

      calculateChildrensWidth = function(e) {
        return e.children().map(function() {
          return $(this).outerWidth(true);
        });
      };

      return FoundationPlayer;

    })();
    return $.fn.extend({
      foundationPlayer: function() {
        var args, option;
        option = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
        if (!$.data(document.body, 'FoundationPlayers')) {
          $.data(document.body, 'FoundationPlayers', []);
        }
        return this.each(function() {
          var fplayer;
          if (!$.data(this, 'FoundationPlayer')) {
            fplayer = new FoundationPlayer(this, option);
            $.data(this, 'FoundationPlayer', fplayer);
            return $.data(document.body, 'FoundationPlayers').push(fplayer);
          }
        });
      }
    });
  })(window.jQuery, window);

}).call(this);
