(function() {
  var slice = [].slice;

  (function($, window) {
    var FoundationPlayer;
    FoundationPlayer = (function() {
      var calculateChildrensWidth, hasCorrectOptions, prettyTime, stringPadLeft, swithClass;

      FoundationPlayer.prototype.defaults = {
        size: 'normal',
        playOnStart: true,
        skipSeconds: 10
      };

      function FoundationPlayer(el, options) {
        this.options = $.extend({}, this.defaults, options);
        this.wavesurfer = Object.create(WaveSurfer);
        this.$wrapper = $(el);
        this.$player = this.$wrapper.children('.player');
        this.$play = this.$wrapper.find('.player-button.play em');
        this.$rewind = this.$wrapper.find('.player-button.rewind em');
        this.$volume = this.$wrapper.find('.player-button.volume em');
        this.$elapsed = this.$wrapper.find('.player-status.time .elapsed');
        this.$remains = this.$wrapper.find('.player-status.time .remains');
        this.timer = null;
        this.init();
      }

      FoundationPlayer.prototype.init = function() {
        if (!hasCorrectOptions(this.options)) {
          return;
        }
        this.setUpClassAndStyle();
        this.setUpWaveSurfer();
        this.setUpButtonPlayPause();
        this.setUpButtonVolume();
        this.setUpButtonRewind();
        this.updateTimeStatuses();
        return this.setUpMainLoop();
      };

      FoundationPlayer.prototype.setUpMainLoop = function() {
        return this.timer = setInterval(this.playerLoopFunctions.bind(this), 100);
      };

      FoundationPlayer.prototype.playerLoopFunctions = function() {
        this.updatePlayedPercentageAttribute();
        this.updateButtonPlay();
        return this.updateTimeStatuses();
      };

      FoundationPlayer.prototype.seekToTime = function(time) {};

      FoundationPlayer.prototype.play = function() {};

      FoundationPlayer.prototype.setUpWaveSurfer = function() {
        this.wavesurfer.init({
          container: this.$wrapper[0],
          waveColor: '#EEEEEE',
          progressColor: '#DDDDDD',
          cursorColor: 'transparent',
          height: 96,
          barWidth: 1,
          skipLength: this.options.skipSeconds
        });
        this.wavesurfer.load(this.options.loadURL);
        if (this.options.playOnStart) {
          this.wavesurfer.on('ready', (function() {
            this.wavesurfer.play();
            return this.updateButtonPlay();
          }).bind(this));
        }
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
          e.data.wavesurfer.playPause();
          return e.data.updateButtonPlay();
        });
      };

      FoundationPlayer.prototype.updateButtonPlay = function() {
        if (this.wavesurfer.isPlaying()) {
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

      FoundationPlayer.prototype.updateTimeStatuses = function() {
        this.updateStatusElapsed();
        return this.updateStatusRemains();
      };

      FoundationPlayer.prototype.updateStatusElapsed = function() {
        return this.$elapsed.text(prettyTime(this.wavesurfer.getCurrentTime()));
      };

      FoundationPlayer.prototype.updateStatusRemains = function() {
        var w;
        w = this.wavesurfer;
        return this.$remains.text('-' + prettyTime(w.getDuration() - w.getCurrentTime()));
      };

      hasCorrectOptions = function(o) {
        if (o.loadURL) {
          return true;
        } else {
          console.error('Please specify `loadURL`. It has no default setings.');
          return false;
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
