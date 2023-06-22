(function (){
  'use strict';

  var session      = require("express-session"),
      RedisStore   = require('connect-redis')(session)

  module.exports = {
    session: {
      name: 'md.sid',
      secret: 'sooper secret',
      resave: false,
      saveUninitialized: true
    },

    session_redis: {
      store: new RedisStore({host: "session-db", user: "root", password: "fake_password"}),
      name: 'md.sid',
      secret: 'sooper secret',
      resave: false,
      saveUninitialized: true
    }
  };
}());