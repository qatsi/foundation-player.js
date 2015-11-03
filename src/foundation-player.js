(function() {
  var slice = [].slice;

  (function($, window) {
    var FoundationPlayer;
    FoundationPlayer = (function() {
      var checkOptions, prettyTime, setUpButtonPlayPause, setUpButtonVolume, setUpClassAndStyle, setUpRangeSlider, setUpWaveSurfer, stringPadLeft, swithClass;

      FoundationPlayer.prototype.defaults = {
        size: 'normal',
        playOnStart: true,
        skipSeconds: 10,
        showWave: true
      };

      function FoundationPlayer(el, options) {
        this.options = $.extend({}, this.defaults, options);
        this.wavesurfer = Object.create(WaveSurfer);
        this.muted = false;
        this.$el = $(el);
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
        setUpButtonPlayPause(this);
        setUpButtonVolume(this);
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

      setUpButtonPlayPause = function(e) {
        var button;
        button = e.$el.find('.player-button.play em');
        button.on('click', e, function() {
          e.wavesurfer.playPause();
          if (e.wavesurfer.isPlaying()) {
            return swithClass(this, 'fi-play', 'fi-pause');
          } else {
            return swithClass(this, 'fi-pause', 'fi-play');
          }
        });
        return e;
      };

      setUpButtonVolume = function(e) {
        var button;
        button = e.$el.find('.player-button.volume em');
        button.on('click', e, function() {
          if (e.muted) {
            e.muted = false;
            e.wavesurfer.toggleMute();
            return swithClass(this, 'fi-volume', 'fi-volume-strike');
          } else {
            e.muted = true;
            e.wavesurfer.toggleMute();
            return swithClass(this, 'fi-volume-strike', 'fi-volume');
          }
        });
        return e;
      };

      FoundationPlayer.prototype.setUpButtonRewind = function() {
        return this.$el.find('.player-button.rewind em').on('click', this.wavesurfer, function(e) {
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
