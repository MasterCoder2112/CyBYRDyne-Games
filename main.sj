'use strict';

//Modules to require
const express = require('express'),
    request = require('request'),
    cookieParser = require("cookie-parser"),
    expressSession = require("express-session"),
    passport = require("passport"),
    FacebookStrategy = require('passport-facebook').Strategy,
    twitter = require('twitter'),
    tweetObjArray = require('./modules/tweetObjArray.js'),
    app = express();

// Sets up our resources folder and its attributes
app.use('/resources', express.static('resources'));

//Setting up pug views
app.set('view engine', 'pug');
app.set('views', './views');

//Parses Json application
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Sets up cookie parser for login cookie
app.use(cookieParser());

// Sets up session handling
app.use(expressSession({
    secret: 'rush2112',
    resave: false,
    saveUninitialized: false
}));

// Initialize passport for password checking
app.use(passport.initialize());

//Make sure session handling was already configured
app.use(passport.session());

// Create the Facebook strategy with my personal given client ID
// and secret key, as well as the url that it will callback to.
passport.use(new FacebookStrategy({
        clientID: '134318110677115',
        clientSecret: 'f78ef514111a6e80b6d83119b982452e',
        callbackURL: 'http://localhost:3000/auth/facebook/callback'
    },
    function(accessToken, refreshToken, profile, callback) {
        //Returns user profile
        return callback(null, profile);
    }));

//Returns the users information
passport.serializeUser(function(user, callback) {
    callback(null, user);
});

//No idea, I just know this is needed.
passport.deserializeUser(function(obj, callback) {
    callback(null, obj);
});

//Authenticate the facebook account
app.get('/auth/facebook', passport.authenticate('facebook'));

//When a response is recieved from facebook, if it was a failiure redirect back to the
//login screen, but otherwise direct to the applet screen.
app.get('/auth/facebook/callback',
    passport.authenticate('facebook', { failureRedirect: '/', successRedirect: '/applet' }));

// Middle ware to make sure the user is authenticated before logging in
let authentication = function(req, res, nextPage) {
    //If authorized
    if (req.isAuthenticated()) {
        return nextPage();
    } else {
        //If failed, send fail status and reload the log in page
        res.redirect('/');
        res.end();
    }
}

//Base address is the login page
app.get('/', function(req, res) {
    res.render('login');
});

//Version history page
app.get('/history', authentication, function(req, res) {
    res.render('history');
});

//Upcoming features page
app.get('/upcoming', authentication, function(req, res) {
    res.render('upcoming');
});

//Browser get function. Requests API from website in the format of json, and
//sends the json object into the pug for the page to use.
app.get('/applet', authentication, function(req, res) {
    res.render('applet');
});

//Uses twitters API to access the tweets with #csc365
app.get('/tweets', authentication, function(req, res) {

    //Allows the site to access the twitter api. This gives the right authentication
    //to access the tweets.
    let client = new twitter({
        consumer_key: "VBZA3jAKo48BVzds8oldpXGCG",
        consumer_secret: "vYJ3hhZYZATk8hzlJFhonKhpQjQxGEx9FRn6RSKKjnQPM5g4Qv",
        access_token_key: "860969835135737857-LNnxtrfl0sw4H2hQnjoxdLAsFHRAtXk",
        access_token_secret: "0wg8gKt3vG0DSrkuaX3FCveA4PURXCikiMaMfSjGUqux5"
    });

    //Uses this client to request tweets with #csc365 in them.
    client.request({
        url: 'https://api.twitter.com/1.1/search/tweets.json',
        qs: {
            q: '#csc365'
        },
        json: true
    }, function(err, response, body) {
        let tweetArray = [];

        //Gets all the tweets from the json object sent in and
        //pushes them into the tweetArray
        for (let i = 0; i < body.statuses.length; i++) {
            let obj = body.statuses[i];

            //The text after being trimmed
            let textTrimmed = trim(obj.text);

            //Calculates the score each tweet will give
            let score = textTrimmed.length * (parseInt(obj.retweet_count) + 1) *
                (parseInt(obj.favorite_count) + 1);

            //Gets the unescaped version of the tweet text
            let text = unescapeText(obj.text);

            //Push new object into tweet array
            tweetArray.push({
                text: text,
                score: score
            });
        }

        //Create a new tweetObjArray
        tweetObjArray.TweetObjArray(tweetArray);

        //If no error was sent back
        if (!err) {
            res.render('tweets', { tweetObjArray: tweetObjArray });
        }
        //Otherwise, print out the error message
        else {
            console.error(error);
        }
    });
});

//The address that allows ajax to access the tweetObjArray object
app.get('/tweets/tweetArray', function(req, res) {
    res.json(tweetObjArray);
});

//Easy way using REGEX to trim the tweet strings
function trim(str) {
    return str.replace(/^\s+|\s+/g, '');
}

//Allows for the characters <> and & to be unescaped back to their original characters.
function unescapeText(escapedText) {
    return escapedText.replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&');
}

//Port the server starts on
const server = app.listen(3000, function() {
    console.log(`Started server on port ${server.address().port}`);
});

/*
created_at: 'Mon Nov 06 23:47:59 +0000 2017',
       id: 927684017008365600,
       id_str: '927684017008365568',
       text: '#csc365 that password though',
       truncated: false,
       entities: [Object],
       metadata: [Object],
       source: '<a href="http://twitter.com/download/android" rel="nofollow">Twitter for Android</a>',
       in_reply_to_status_id: null,
       in_reply_to_status_id_str: null,
       in_reply_to_user_id: null,
       in_reply_to_user_id_str: null,
       in_reply_to_screen_name: null,
       user: [Object],
       geo: null,
       coordinates: null,
       place: null,
       contributors: null,
       is_quote_status: false,
       retweet_count: 0,
       favorite_count: 0,
       favorited: false,
       retweeted: false,
       lang: 'en' },*/