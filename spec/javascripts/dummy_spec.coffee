describe 'CoffeeScript suite', ->
  beforeEach ->
    jasmine.getFixtures().load 'player.html'
    $('.no-1').foundationPlayer()
    no1 = $('.no-1').data 'FoundationPlayer'

  it 'it has CoffeeScript suppot:)', ->
    expect(true).toBe true
    expect(false).not.toBe true
