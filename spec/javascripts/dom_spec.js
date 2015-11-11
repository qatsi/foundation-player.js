describe("A suite", function() {
  beforeEach(function() {
    jasmine.getFixtures().load('no-1.html')
    $('.no-1').foundationPlayer()
    no1 = $('.no-1').data('FoundationPlayer');
  });

  it("Initialized player is in DOM", function() {
    expect(no1).toBeDefined();
  });
  it("player has default size", function() {
    expect(no1.options.size).toEqual('normal');
  });
});
