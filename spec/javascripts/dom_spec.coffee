describe 'CoffeeScript suite', ->
  no1 = 0
  beforeEach ->
    loadFixtures 'player.html'
    $('.no-1').foundationPlayer()
    no1 = $('.no-1').data 'FoundationPlayer'
  afterEach ->
    no1 = 0

  it 'it has CoffeeScript support:)', ->
    expect(true).toBe true
    expect(false).not.toBe true

  it 'Initialized player?', ->
    expect(no1).toBeDefined()

  it 'player has default size', ->
    expect(no1.currentUISize).toEqual no1.options.size
  it 'play() works', ->
    no1.play()
    expect(no1.audio.paused).toEqual false
  it 'paused() works', ->
    no1.pause()
    expect(no1.audio.paused).toEqual true
  it 'playPause() works', ->
    no1.pause()
    no1.playPause()
    expect(no1.audio.paused).toEqual false
    no1.playPause()
    expect(no1.audio.paused).toEqual true
  it 'setVolume() works', ->
    no1.setVolume 0.5
    expect(no1.audio.volume).toEqual 0.5
  it 'setPlayerSize() works', ->
    no1.setPlayerSize 'small'
    expect(no1.currentUISize).toEqual 'small'
  it 'togglePlayerSize() works', ->
    no1.setPlayerSize 'small'
    no1.togglePlayerSize()
    expect(no1.currentUISize).toEqual 'normal'
    no1.togglePlayerSize()
    expect(no1.currentUISize).toEqual 'small'
  it 'toggleMute() works', ->
    no1.audio.muted = false
    no1.toggleMute()
    expect(no1.audio.muted).toEqual true
    no1.toggleMute()
    expect(no1.audio.muted).toEqual false