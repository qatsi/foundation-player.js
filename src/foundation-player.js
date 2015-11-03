(function() {
  var slice = [].slice;

  (function($, window) {
    var FoundationPlayer;
    FoundationPlayer = (function() {
      var checkOptions, setUpButtonPlayPause, setUpClassAndStyle, setUpRangeSlider, setUpWaveSurfer;

      FoundationPlayer.prototype.defaults = {
        size: 'normal',
        playOnStart: true,
        showWave: true
      };

      function FoundationPlayer(el, options) {
        this.options = $.extend({}, this.defaults, options);
        this.wavesurfer = Object.create(WaveSurfer);
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
        return setUpRangeSlider(this.$el);
      };

      FoundationPlayer.prototype.seekToTime = function(time) {};

      FoundationPlayer.prototype.play = function() {};

      setUpRangeSlider = function(element) {};

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
        return e.addClass(o.size);
      };

      setUpButtonPlayPause = function(e) {
        var button;
        button = e.$el.find('.player-button.play em');
        button.on('click', e, function() {
          e.wavesurfer.playPause();
          if (e.wavesurfer.isPlaying()) {
            return $(this).addClass('fi-play').removeClass('fi-pause');
          } else {
            return $(this).addClass('fi-pause').removeClass('fi-play');
          }
        });
      };

      checkOptions = function(o) {
        if (o.loadURL) {
          return true;
        } else {
          console.error('Please specify `loadURL`. It has no default setings.');
          return false;
        }
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
