describe('ReportsCtrl controller', function() {

  'use strict';

  var createController,
      scope;

  beforeEach(module('inboxApp'));

  beforeEach(inject(function($rootScope, $controller) {
    scope = $rootScope.$new();
    scope.filterModel = {};
    scope.selectedMessage = 'a';
    scope.selectMessage = function(msg) {
      scope.selectedMessage = msg;
    };

    createController = function() {
      return $controller('ReportsCtrl', {
        '$scope': scope,
        '$route': { current: { params: { doc: 'x' } } }
      });
    };
  }));

  it('set up controller', function() {
    createController();
    chai.expect(scope.filterModel.type).to.equal('reports');
    chai.expect(scope.selectedMessage).to.equal('x');
  });

});