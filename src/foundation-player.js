(function() {
  var slice = [].slice;

  (function($, window) {
    var FoundationPlayer;
    FoundationPlayer = (function() {
      var checkOptions, setUpClass, setUpRangeSlider, setUpWaveSurfer;

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
        setUpClass(this.$el, this.options);
        if (!checkOptions(this.options)) {
          return;
        }
        setUpRangeSlider(this.$el);
        setUpWaveSurfer(this);
        return window.wtf = this;
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

      setUpClass = function(e, o) {
        return e.addClass(o.size);
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
