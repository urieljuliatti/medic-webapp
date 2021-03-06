var _ = require('underscore');

(function () {

  'use strict';

  var inboxServices = angular.module('inboxServices');

  inboxServices.factory('SaveDoc', ['db',
    function(db) {

      var getDoc = function(id, callback) {
        if (!id) {
          return callback(null, {});
        }
        db.getDoc(id, callback);
      };

      return function(id, updates, callback) {
        if (!callback) {
          callback = updates;
          updates = id;
          id = null;
        }
        getDoc(id, function(err, doc) {
          if (err) {
            return callback(err);
          }
          doc = _.extend(doc, updates);
          db.saveDoc(doc, function(err, res) {
            if (!doc._id) {
              // new doc added, return the id
              doc._id = res.id;
            }
            callback(err, doc);
          });
        });
      };
    }
  ]);

}());