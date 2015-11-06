# Foundation-player.js

Dead simple player plugin for [Foundation](http://foundation.zurb.com/). The [demo](http://qatsi.github.io/foundation-player.js/index.html).

`Foundation-player.js` featuring:
- Waveform generation
- `Play`/`Puase` buttons!
- All you looking from a player… will be added soon

## Install

Make sure assets below added after `foundation.js`  and `foundation.css`.

```
<script type='text/javascript' src='../src/foundation-player.js'></script>
<link href='../src/foundation-player.css' rel='stylesheet' type='text/css'>
```

Create a `password` input field within `form`.

```
<form class='player player-1'>
...
<input class='radius' type='password' placeholder='Password'>
...
</form>
```

Initiate the plugin.

```
<script>
  $(document).ready(function($) {
    $('.player-1').player();
    $(document).foundation();
  });
</script>
```

## Development
Just run `bundle install` and `guard`.
These files generated by `guard`, so don't edit them:
- **JavaScript** `src/foundation-player.js` and `src/foundation-player.min.js` use `src/foundation-player.coffee` instead
- **CSS** `src/foundation-player.css` take a look in `src/foundation-player.scss`
- **HTML5** `index.html` edit `index.haml`

### Run

Fire up `ruby -run -e httpd . -p 9090` in console inside project folder.

## MIME Types

Small cheatsheet with audio MIME types:

- `audio/aac` .aac
- `audio/mp4` .mp4 .m4a
- `audio/mpeg` .mp1 .mp2 .mp3 .mpg .mpeg
- `audio/ogg` .oga .ogg
- `audio/wav` .wav
- `audio/webm` .webm

## Todo
- Playlists
- `Next`/`Prev` buttons
- Shut other players if any
