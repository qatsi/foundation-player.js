(function() {
  var slice = [].slice;

  (function($, window) {
    var FoundationPlayer;
    FoundationPlayer = (function() {
      var calculateChildrensWidth, forceRange, isNumber, prettyTime, stringPadLeft, switchClass;

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
        return this.updateButtonPlay();
      };

      FoundationPlayer.prototype.play = function() {
        this.audio.play();
        return this.updateButtonPlay();
      };

      FoundationPlayer.prototype.pause = function() {
        this.audio.pause();
        return this.updateButtonPlay();
      };

      FoundationPlayer.prototype.seekToTime = function(time) {
        var m;
        if (isNumber(time)) {
          this.audio.currentTime = forceRange(time, this.audio.duration);
        } else if (m = time.match(/^(\d{0,3})$/)) {
          this.audio.currentTime = forceRange(m[1], this.audio.duration);
        } else if (m = time.match(/^(\d?\d):(\d\d)$/)) {
          time = (parseInt(m[1], 10)) * 60 + (parseInt(m[2], 10));
          this.audio.currentTime = forceRange(time, this.audio.duration);
        } else {
          console.error("seekToTime(time), invalid argument: " + time);
        }
        this.updatePlayedProgress();
        this.updateTimeStatuses();
        return this;
      };

      FoundationPlayer.prototype.seekPercent = function(p) {
        this.audio.currentTime = this.audio.duration * (p >= 1 ? p / 100 : p);
        this.updatePlayedProgress();
        this.updateTimeStatuses();
        return this;
      };

      FoundationPlayer.prototype.resetClassAndStyle = function() {
        this.$wrapper.addClass(this.options.size);
        return this.setPlayerSizeHandler();
      };

      FoundationPlayer.prototype.setUpButtonPlayPause = function() {
        return this.$play.bind('click', (function(_this) {
          return function() {
            return _this.playPause();
          };
        })(this));
      };

      FoundationPlayer.prototype.updateButtonPlay = function() {
        if (this.audio.paused) {
          switchClass(this.$play, 'fi-pause', 'fi-play');
        } else {
          switchClass(this.$play, 'fi-play', 'fi-pause');
        }
        return this;
      };

      FoundationPlayer.prototype.setUpButtonVolume = function() {
        return this.$volume.bind('click', (function(_this) {
          return function() {
            _this.toggleMute();
            return _this.updateButtonVolume();
          };
        })(this));
      };

      FoundationPlayer.prototype.updateButtonVolume = function() {
        if (this.audio.muted) {
          return switchClass(this.$volume, 'fi-volume-strike', 'fi-volume');
        } else {
          return switchClass(this.$volume, 'fi-volume', 'fi-volume-strike');
        }
      };

      FoundationPlayer.prototype.setUpButtonRewind = function() {
        return this.$rewind.on('click', (function(_this) {
          return function() {
            return _this.seekToTime(_this.audio.currentTime - _this.options.skipSeconds);
          };
        })(this));
      };

      FoundationPlayer.prototype.setUpPlayedProgress = function() {
        this.$played.css('width', this.played + '%');
        this.$progress.on('click.fndtn.player', (function(_this) {
          return function(e) {
            return _this.seekPercent(Math.floor(e.offsetX / _this.$progress.outerWidth() * 100));
          };
        })(this));
        this.$progress.on('mousedown.fndtn.player', (function(_this) {
          return function() {
            _this.nowdragging = true;
            return _this.setVolume(_this.options.dimmedVolume);
          };
        })(this));
        $(document).on('mouseup.fndtn.player', (function(_this) {
          return function() {
            if (_this.nowdragging) {
              _this.nowdragging = false;
              return _this.setVolume(1);
            }
          };
        })(this));
        this.$progress.on('mouseup.fndtn.player', (function(_this) {
          return function() {
            if (_this.nowdragging) {
              _this.nowdragging = false;
              return _this.setVolume(1);
            }
          };
        })(this));
        return this.$progress.on('mousemove.fndtn.player', (function(_this) {
          return function(e) {
            if (_this.nowdragging) {
              return _this.seekPercent(Math.floor(e.offsetX / _this.$progress.outerWidth() * 100));
            }
          };
        })(this));
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
        this.$wrapper.addClass(swithToSize).removeClass(this.currentPlayerSize);
        this.setPlayerSizeHandler();
        return this.currentPlayerSize = swithToSize;
      };

      FoundationPlayer.prototype.setPlayerSize = function(size) {
        if (('normal' === size || 'small' === size) && size !== this.currentPlayerSize) {
          this.$wrapper.addClass(size).removeClass(this.currentPlayerSize);
          this.setPlayerSizeHandler();
          return this.currentPlayerSize = size;
        } else {
          console.error('setPlayerSize: incorrect size argument');
          return false;
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

      switchClass = function(element, p, n) {
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

      isNumber = function(x) {
        return typeof x === 'number' && isFinite(x);
      };

      forceRange = function(x, max) {
        if (x < 0) {
          return 0;
        }
        if (x > max) {
          return max;
        }
        return x;
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
