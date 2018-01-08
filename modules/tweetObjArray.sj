'use strict';

const tweetObjArray = {};

tweetObjArray.TweetObjArray = function(array) {
	this._tweets = array;
};

tweetObjArray.getScore = function(index) {
	return decodeURI(this._tweets[index].score);
};

tweetObjArray.setScore = function(newScore, index) {
	this._tweets[index].score = newScore;
};

tweetObjArray.getText = function(index) {
	return decodeURI(this._tweets[index].text);
};

tweetObjArray.setText = function(newText, index) {
	this._tweets[index].text = newText;
};

tweetObjArray.getTweet = function(index) {
	return this._tweets[index];
};

tweetObjArray.getArray = function() {
	return this._tweets;
};

module.exports = tweetObjArray;