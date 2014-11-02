// background.js
// Does everything.

var populate_tabs = function (callback) {
	// Loop through all the windows.
	chrome.windows.getAll({ populate: true }, function (windows) {
		var tabs = [];
		console.log(windows);

		for (var i = 0; i < windows.length; i++) {
			if (windows[i].type == "normal") {
				for (var j = 0; j < windows[i].tabs.length; j++) {
					if (windows[i].tabs[j].url.match(/^chrome\:\/\//i) == null) {
						tabs.push(windows[i].tabs[j]);
					}
				}
			}
		}

		callback(tabs);
	});
};

/*

// Window events.
chrome.windows.onCreated.addListener(function (createInfo) {
	console.log("Window: onCreated");
	populate_tabs(function (tabs) {
		console.log(tabs);
	});
});

chrome.windows.onRemoved.addListener(function (windowId) {
	console.log("Window: onRemoved");
	populate_tabs(function (tabs) {
		console.log(tabs);
	});
});

// Tab events.
chrome.tabs.onCreated.addListener(function (tab) {
	console.log("Tab: onCreated");
	populate_tabs(function (tabs) {
		console.log(tabs);
	});
});

chrome.tabs.onAttached.addListener(function (tabId, props) {
	console.log("Tab: onAttached");
	populate_tabs(function (tabs) {
		console.log(tabs);
	});
});

chrome.tabs.onMoved.addListener(function (tabId, props) {
	console.log("Tab: onMoved");
	populate_tabs(function (tabs) {
		console.log(tabs);
	});
});

chrome.tabs.onUpdated.addListener(function(tabId, props) {
	console.log("Tab: onMoved");
	populate_tabs(function (tabs) {
		console.log(tabs);
	});
});

chrome.tabs.onDetached.addListener(function(tabId, props) {
	console.log("Tab: onMoved");
	populate_tabs(function (tabs) {
		console.log(tabs);
	});
});

chrome.tabs.onRemoved.addListener(function(tabId) {
	console.log("Tab: onMoved");
	populate_tabs(function (tabs) {
		console.log(tabs);
	});
});

*/

// Init.
populate_tabs(function (tabs) {
	console.log(tabs);
});

