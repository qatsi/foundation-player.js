describe("Initialized player", function() {
  beforeEach(function() {
    jasmine.getFixtures().load('player.html')
    $('.no-1').foundationPlayer()
    player = $('.no-1').data('FoundationPlayer');
  });

  it("Initialized player is in DOM", function() {
    expect(player).toBeDefined();
  });
  it("player has default size", function() {
    expect(player.options.size).toEqual('normal');
  });
  

});
