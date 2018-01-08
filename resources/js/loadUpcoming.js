'use strict';

let upcoming = new XMLHttpRequest();

upcoming.open('GET', './resources/text/versionUpcoming.txt');
upcoming.addEventListener('load', function() {
	let text = upcoming.response;
	let versions = text.split('|');

	versions.forEach(function(version) {
		let elements = version.split(':');
		let list = document.querySelector('.versionList');
		let divBox = document.createElement('div');
		let listNode = document.createElement('li');
		let textNode = document.createTextNode(decodeURI(elements[1].trim()));
		let versionNum = document.createTextNode(decodeURI(elements[0].trim() + ':'));
		listNode.appendChild(textNode);
		divBox.appendChild(versionNum);
		divBox.appendChild(listNode);
		divBox.className = 'lists';
		list.appendChild(divBox);
	});
});

upcoming.timeout = 10 * 1000;
upcoming.addEventListener('timeout', function(err) {
	console.error(err);
});

upcoming.addEventListener('error', function(err) {
	console.error(err);
});

upcoming.send();