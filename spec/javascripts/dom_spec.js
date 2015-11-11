//Player just created, non animate

describe("Initialized player", function() {
  beforeEach(function() {
    jasmine.getFixtures().load('player.html')
    $('.no-1').foundationPlayer()
    player = $('.no-1').data('FoundationPlayer');
  });


  it("Initialized player?", function() {
    expect(player).toBeDefined();
  });

  it("player has default size", function() {
    expect(player.currentUISize).toEqual(player.options.size);
  });
//API tests:
//player.play()
//player.pause()
//player.playPause()
  it("play() works", function() {
    player.play()
    expect(player.audio.paused).toEqual(false);
  });

  it("paused() works", function() {
    player.pause()
    expect(player.audio.paused).toEqual(true);
  });

  it("playPause() works", function() {
    player.pause()
    player.playPause()
    expect(player.audio.paused).toEqual(false);
    player.playPause()
    expect(player.audio.paused).toEqual(true);
  });

  it("setVolume() works", function() {
    player.setVolume(0.5)
    expect(player.audio.volume).toEqual(0.5);
  });

  it("setPlayerSize() works", function() {
   player.setPlayerSize('small')
   expect(player.currentUISize).toEqual('small');
  });

  it("togglePlayerSize() works", function() {
   player.setPlayerSize('small')
   player.togglePlayerSize()
   expect(player.currentUISize).toEqual('normal');
   player.togglePlayerSize()
   expect(player.currentUISize).toEqual('small');
  });

  it("toggleMute() works", function() {
   player.audio.muted = false
   player.toggleMute()
   expect(player.audio.muted).toEqual(true);
   player.toggleMute()
   expect(player.audio.muted).toEqual(false);
  });


});


describe("UI exists", function() {
  beforeEach(function() {
    jasmine.getFixtures().load('player.html')
    $('.no-1').foundationPlayer()
    player1 = $('.no-1').data('FoundationPlayer');
  });

  it("CSS", function() {
    expect($('.foundation-player')).toHaveClass("foundation-player")
    expect($('.random-player')).toHaveClass("foundation-player")
  });

});
//changes in defaults.



// changes in animate @options.animate = true affects
// updatePlayedProgress:
// seekToTime, seekPercent, setUpCurrentAudio
// setVolume:
// @$progress.on 'mousedown.fndtn.player',  () =>
//_stopDragHandler = () =>
