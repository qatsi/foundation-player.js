(function() {
  var slice = [].slice;

  (function($, window) {
    var FoundationPlayer;
    FoundationPlayer = (function() {
      var checkOptions, setUpButtonPlayPause, setUpButtonVolume, setUpClassAndStyle, setUpRangeSlider, setUpWaveSurfer, swithClass;

      FoundationPlayer.prototype.defaults = {
        size: 'normal',
        playOnStart: true,
        showWave: true
      };

      function FoundationPlayer(el, options) {
        this.options = $.extend({}, this.defaults, options);
        this.wavesurfer = Object.create(WaveSurfer);
        this.muted = false;
        this.$el = $(el);
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
        return setUpRangeSlider(this);
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
          skipLength: 15
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
