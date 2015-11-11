(function() {
  describe('CoffeeScript suite', function() {
    beforeEach(function() {
      var no1;
      jasmine.getFixtures().load('player.html');
      $('.no-1').foundationPlayer();
      return no1 = $('.no-1').data('FoundationPlayer');
    });
    return it('it has CoffeeScript suppot:)', function() {
      expect(true).toBe(true);
      return expect(false).not.toBe(true);
    });
  });

}).call(this);
