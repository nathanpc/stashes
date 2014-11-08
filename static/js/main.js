// main.js
// Everything Javascript.

window.onload = function () {
	fetch_tabs(function (json) {
		var browsers = [];

		for (var i = 0; i < json.browsers.length; i++) {
			var browser = json.browsers[i];
			browser.tabs = [];

			for (var j = 0; j < json.tabs.length; j++) {
				var tab = json.tabs[j];
				if (tab.browser_id == browser.id) {
					browser.tabs.push(tab);
				}
			}

			browsers.push(browser);
		}

		populate_tabs(browsers);
	});
};

var fetch_tabs = function (callback) {
	var req = new XMLHttpRequest();
	req.onreadystatechange = function () {
		if (req.readyState == XMLHttpRequest.DONE) {
			if (req.status == 200) {
				callback(JSON.parse(req.responseText));
			} else {
				alert("Couldn't fetch tabs.");
				console.log("ERROR!");
			}
		}
	};

	req.open("GET", "/list", true);
	req.send();
};

var populate_tabs = function (browsers) {
	for (var i = 0; i < browsers.length; i++) {
		var browser = browsers[i];

		var panel = document.createElement("div");
		panel.setAttribute("class", "panel panel-default");

		var phead = document.createElement("div");
		phead.setAttribute("class", "panel-heading");
		var phead_lbl = document.createElement("h3");
		phead_lbl.setAttribute("class", "panel-title");
		var browser_ico = document.createElement("img");
		browser_ico.src = "img/google-chrome.png";
		phead_lbl.appendChild(browser_ico);
		phead_lbl.appendChild(document.createTextNode(browser.name));
		phead.appendChild(phead_lbl);
		panel.appendChild(phead);

		var list = document.createElement("ul");
		list.setAttribute("class", "list-group");
		for (var j = 0; j < browser.tabs.length; j++) {
			var tab = browser.tabs[j];

			var item = document.createElement("a");
			item.setAttribute("class", "list-group-item");
			item.href = tab.url;

			var favicon = document.createElement("img");
			favicon.onerror = function () {
				favicon.src = "img/nofavicon.png";
			};
			if (tab.favicon != null) {
				favicon.src = tab.favicon;
			} else {
				favicon.src = "img/nofavicon.png";
			}

			item.appendChild(favicon);
			item.appendChild(document.createTextNode(tab.title));
			list.appendChild(item);
		}

		panel.appendChild(list);
		document.getElementById("tabs").insertBefore(panel, document.getElementById("tabs").firstChild);
	}
};

