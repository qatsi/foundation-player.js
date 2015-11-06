(function() {
  var slice = [].slice;

  (function($, window) {
    var FoundationPlayer;
    FoundationPlayer = (function() {
      var calculateChildrensWidth, prettyTime, stringPadLeft, swithClass;

      FoundationPlayer.prototype.defaults = {
        size: 'normal',
        playOnStart: true,
        skipSeconds: 10
      };

      function FoundationPlayer(el, options) {
        this.options = $.extend({}, this.defaults, options);
        this.$wrapper = $(el);
        this.$player = this.$wrapper.children('.player');
        this.audio = this.$wrapper.children('audio').get(0);
        this.$play = this.$wrapper.find('.player-button.play em');
        this.$rewind = this.$wrapper.find('.player-button.rewind em');
        this.$volume = this.$wrapper.find('.player-button.volume em');
        this.$elapsed = this.$wrapper.find('.player-status.time .elapsed');
        this.$remains = this.$wrapper.find('.player-status.time .remains');
        this.$progress = this.$wrapper.find('.player-progress .progress');
        this.$played = this.$progress.find('.meter');
        this.timer = null;
        this.played = 0;
        this.init();
      }

      FoundationPlayer.prototype.init = function() {
        this.setUpClassAndStyle();
        this.setUpButtonPlayPause();
        this.setUpButtonVolume();
        this.setUpButtonRewind();
        this.setUpPlayedProgress();
        this.updateTimeStatuses();
        return this.setUpMainLoop();
      };

      FoundationPlayer.prototype.setUpMainLoop = function() {
        return this.timer = setInterval(this.playerLoopFunctions.bind(this), 200);
      };

      FoundationPlayer.prototype.playerLoopFunctions = function() {
        this.updateButtonPlay();
        this.updateTimeStatuses();
        return this.updatePlayedProgress();
      };

      FoundationPlayer.prototype.seekToTime = function(time) {};

      FoundationPlayer.prototype.playPause = function() {
        if (this.audio.paused) {
          this.audio.play();
        } else {
          this.audio.pause();
        }
        return this.updateButtonPlay();
      };

      FoundationPlayer.prototype.setUpClassAndStyle = function() {
        var actualWidth, playerWidth;
        this.$wrapper.addClass(this.options.size);
        actualWidth = this.$player.width();
        playerWidth = 0;
        calculateChildrensWidth(this.$player).each(function() {
          return playerWidth += this;
        });
        return this.$player.width(Math.floor(5 + playerWidth / actualWidth * 100) + '%');
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
          e.data.wavesurfer.toggleMute();
          return e.data.updateButtonVolume();
        });
      };

      FoundationPlayer.prototype.updateButtonVolume = function() {
        if (this.wavesurfer.isMuted) {
          return swithClass(this.$volume, 'fi-volume-strike', 'fi-volume');
        } else {
          return swithClass(this.$volume, 'fi-volume', 'fi-volume-strike');
        }
      };

      FoundationPlayer.prototype.setUpButtonRewind = function() {
        return this.$rewind.on('click', this, function(e) {
          return e.data.wavesurfer.skipBackward();
        });
      };

      FoundationPlayer.prototype.setUpPlayedProgress = function() {
        var semiHeight;
        if (this.$progress.hasClass('round')) {
          semiHeight = this.$played.height() / 2;
          this.$played.css('padding', "0 " + semiHeight + "px");
        }
        return this.$played.css('width', this.played + '%');
      };

      FoundationPlayer.prototype.updatePlayedProgress = function() {
        this.played = Math.round(this.audio.currentTime / this.audio.duration * 100);
        return this.$played.css('width', this.played + '%');
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
