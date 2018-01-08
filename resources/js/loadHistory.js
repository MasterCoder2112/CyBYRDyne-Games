'use strict';

let history = new XMLHttpRequest();

history.open('GET', './resources/text/versionHistory.txt');
history.addEventListener('load', function() {
	let text = history.response;
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

history.timeout = 10 * 1000;
history.addEventListener('timeout', function(err) {
	console.error(err);
});

history.addEventListener('error', function(err) {
	console.error(err);
});

history.send();