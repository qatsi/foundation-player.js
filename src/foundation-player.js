(function() {
  var slice = [].slice;

  (function($, window) {
    var FoundationPlayer;
    FoundationPlayer = (function() {
      var checkOptions, prettyTime, setUpClassAndStyle, setUpRangeSlider, setUpWaveSurfer, stringPadLeft, swithClass;

      FoundationPlayer.prototype.defaults = {
        size: 'normal',
        playOnStart: true,
        skipSeconds: 10
      };

      function FoundationPlayer(el, options) {
        this.options = $.extend({}, this.defaults, options);
        this.wavesurfer = Object.create(WaveSurfer);
        this.$el = $(el);
        this.$play = $(el).find('.player-button.play em');
        this.$rewind = $(el).find('.player-button.rewind em');
        this.$volume = $(el).find('.player-button.volume em');
        this.$elapsed = $(el).find('.player-status.time .elapsed');
        this.$remains = $(el).find('.player-status.time .remains');
        this.init();
      }

      FoundationPlayer.prototype.init = function() {
        if (!checkOptions(this.options)) {
          return;
        }
        setUpClassAndStyle(this.$el, this.options);
        setUpWaveSurfer(this);
        this.setUpButtonPlayPause();
        this.setUpButtonVolume();
        this.setUpButtonRewind();
        this.updateStatus();
        setUpRangeSlider(this);
      };

      FoundationPlayer.prototype.seekToTime = function(time) {};

      FoundationPlayer.prototype.play = function() {};

      setUpWaveSurfer = function(e) {
        e.wavesurfer.init({
          container: e.$el[0],
          waveColor: '#EEEEEE',
          progressColor: '#DDDDDD',
          cursorColor: 'transparent',
          height: 96,
          barWidth: 1,
          skipLength: e.options.skipSeconds
        });
        if (e.options.playOnStart) {
          e.wavesurfer.on('ready', function() {
            return e.wavesurfer.play();
          });
        }
        e.wavesurfer.load(e.options.loadURL);
      };

      setUpClassAndStyle = function(e, o) {
        e.addClass(o.size);
        return e;
      };

      FoundationPlayer.prototype.setUpButtonPlayPause = function() {
        return this.$play.bind('click', this, function(e) {
          e.data.wavesurfer.playPause();
          return e.data.updateButtonPlay();
        });
      };

      FoundationPlayer.prototype.updateButtonPlay = function() {
        if (this.wavesurfer.isPlaying()) {
          swithClass(this.$play, 'fi-play', 'fi-pause');
        } else {
          swithClass(this.$play, 'fi-pause', 'fi-play');
        }
        return this;
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
        return this.$rewind.on('click', this.wavesurfer, function(e) {
          return e.data.skipBackward();
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

      setUpRangeSlider = function(e) {};

      checkOptions = function(o) {
        if (o.loadURL) {
          return true;
        } else {
          console.error('Please specify `loadURL`. It has no default setings.');
          return false;
        }
      };

      swithClass = function(e, from, to) {
        return $(e).addClass(from).removeClass(to);
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
