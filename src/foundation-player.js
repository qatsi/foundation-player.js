(function() {
  var slice = [].slice;

  (function($, window) {
    var FoundationPlayer;
    FoundationPlayer = (function() {
      var hasCorrectOptions, prettyTime, stringPadLeft, swithClass;

      FoundationPlayer.prototype.defaults = {
        size: 'normal',
        playOnStart: true,
        skipSeconds: 10
      };

      function FoundationPlayer(el, options) {
        this.options = $.extend({}, this.defaults, options);
        this.wavesurfer = Object.create(WaveSurfer);
        this.$el = $(el);
        this.$play = this.$el.find('.player-button.play em');
        this.$rewind = this.$el.find('.player-button.rewind em');
        this.$volume = this.$el.find('.player-button.volume em');
        this.$elapsed = this.$el.find('.player-status.time .elapsed');
        this.$remains = this.$el.find('.player-status.time .remains');
        this.$slider = this.$el.find('.player-sliderbar .range-slider');
        this.playedPercentage = 0;
        this.sliderPosition = 0;
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
        this.setUpRangeSlider();
        this.updateStatus();
        return this.setUpMainLoop();
      };

      FoundationPlayer.prototype.setUpMainLoop = function() {
        return this.timer = setInterval(this.playerLoopFunctions.bind(this), 1000);
      };

      FoundationPlayer.prototype.playerLoopFunctions = function() {
        this.updatePercentage();
        this.updateStatus();
        return this.updateSliderPosition();
      };

      FoundationPlayer.prototype.seekToTime = function(time) {};

      FoundationPlayer.prototype.play = function() {};

      FoundationPlayer.prototype.setUpWaveSurfer = function() {
        var wavesurfer;
        this.wavesurfer.init({
          container: this.$el[0],
          waveColor: '#EEEEEE',
          progressColor: '#DDDDDD',
          cursorColor: 'transparent',
          height: 96,
          barWidth: 1,
          skipLength: this.options.skipSeconds
        });
        this.wavesurfer.load(this.options.loadURL);
        wavesurfer = this.wavesurfer;
        if (this.options.playOnStart) {
          this.wavesurfer.on('ready', function() {
            return wavesurfer.play();
          });
        }
      };

      FoundationPlayer.prototype.setUpClassAndStyle = function() {
        return this.$el.addClass(this.options.size);
      };

      FoundationPlayer.prototype.setUpButtonPlayPause = function() {
        return this.$play.bind('click', this, function(e) {
          e.data.wavesurfer.playPause();
          return e.data.updateButtonPlay();
        });
      };

      FoundationPlayer.prototype.updateButtonPlay = function() {
        if (this.wavesurfer.isPlaying()) {
          return swithClass(this.$play, 'fi-play', 'fi-pause');
        } else {
          return swithClass(this.$play, 'fi-pause', 'fi-play');
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
          e.data.wavesurfer.skipBackward();
          return e.data.updateSlider();
        });
      };

      FoundationPlayer.prototype.updateStatus = function() {
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

      FoundationPlayer.prototype.updateSlider = function() {
        this.updatePercentage();
        return this.updateSliderPosition();
      };

      FoundationPlayer.prototype.updateSliderPosition = function() {};

      FoundationPlayer.prototype.updatePercentage = function() {
        var w;
        w = this.wavesurfer;
        return this.playedPercentage = Math.floor((w.getCurrentTime() / w.getDuration()) * 100);
      };

      FoundationPlayer.prototype.updateSliderPercentage = function() {
        return this.sliderPosition = this.$slider.attr('data-slider');
      };

      FoundationPlayer.prototype.setUpRangeSlider = function() {
        return this.$slider.on('change.fndtn.slider', (function() {
          return this.updatePlayerPosition();
        }).bind(this));
      };

      FoundationPlayer.prototype.updatePlayerPosition = function() {
        this.wavesurfer.seekTo(this.updateSliderPercentage() / 100);
        return this.updateStatus();
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
