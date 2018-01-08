'use strict';

//Create an XMLHttpRequest using ajax to the server
let xhrArray = new XMLHttpRequest();
let score = 0;
let tweetObjArray = {};

//Get the tweetArray object from the web address
xhrArray.open('GET', 'http://localhost:3000/tweets/tweetArray');

//After the object has been loaded in, set the object equal to the
//tweetObjArray object and then call the addListeners function so
//that the listeners are only added after the object has been loaded
xhrArray.addEventListener('load', function() {
	tweetObjArray = JSON.parse(xhrArray.response);
	addListeners();
});

//Timeout after 5 seconds of waiting
xhrArray.timeout = 5 * 1000;

//If a timeout event happens.
xhrArray.addEventListener('timeout', function(err) {
	console.error(err);
});

//If error occurs
xhrArray.addEventListener('error', function(err) {
	console.error(err);
});

//Send status back to browser
xhrArray.send();

/*
 * Adds listeners to each li object, so that when the li object is
 * clicked, the tweet is removed from the list, and the tweets score
 * is added to the overall score, and the Score display at the top
 * of the page is updated. Also an audio file of an explosion is
 * played when a successful click occurs.
 */
let addListeners = function() {
	document.querySelectorAll('.lists').forEach(function(item) {
		item.addEventListener('click', function() {
			item.parentNode.removeChild(item);
			let index = getIndex(item.lastChild.textContent, tweetObjArray._tweets);
			console.log(index);
			try {
				score += tweetObjArray._tweets[index].score;

				let audio = new Audio('./resources/audio/explosion.mp3');
				audio.play();

				let newArray = [];

				//Reset the tweets array by deleting the index clicked on
				for (let i = 0; i < tweetObjArray._tweets.length; i++) {
					//As long as its not the index to be deleted
					if (i !== index) {
						newArray.push(tweetObjArray._tweets[i]);
					}
				}

				//Resets the array.
				tweetObjArray._tweets = newArray;

			} catch (err) {
				score += 0;
				console.error(err);
			}

			document.querySelector('#header').innerHTML = 'SCORE: ' + score;
		});
	});
};

//A function used to get the index of the array where the text 
//clicked is the same as the text of the tweet at that index of
//the array.
function getIndex(text, array) {
	for (let i = 0; i < array.length; i++) {
		if (text === array[i].text) {
			return i;
		}
	}
	return -1;
}