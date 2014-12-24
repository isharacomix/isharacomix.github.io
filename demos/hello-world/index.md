---
layout: post
title: Hello World!
type: demo
shortname: hello-world
date: 2015-01-01
---

<script type="text/javascript" src="{{site.baseurl}}js/gameboy/other/windowStack.js" ></script>
<script type="text/javascript" src="{{site.baseurl}}js/gameboy/other/terminal.js"></script>
<script type="text/javascript" src="{{site.baseurl}}js/gameboy/other/gui.js"></script>
<script type="text/javascript" src="{{site.baseurl}}js/gameboy/other/base64.js"></script>
<script type="text/javascript" src="{{site.baseurl}}js/gameboy/other/json2.js"></script>
<script type="text/javascript" src="{{site.baseurl}}js/gameboy/other/swfobject.js"></script>
<script type="text/javascript" src="{{site.baseurl}}js/gameboy/other/resampler.js"></script>
<script type="text/javascript" src="{{site.baseurl}}js/gameboy/other/XAudioServer.js"></script>
<script type="text/javascript" src="{{site.baseurl}}js/gameboy/other/resize.js"></script>
<script type="text/javascript" src="{{site.baseurl}}js/gameboy/GameBoyCore.js"></script>
<script type="text/javascript" src="{{site.baseurl}}js/gameboy/GameBoyIO.js"></script>


<div id="GameBoy" class="window">
<div class="menubar">
<span id="GameBoy_file_menu">File</span>
<span id="GameBoy_settings_menu">Settings</span>
<span id="GameBoy_view_menu">View</span>
<span id="GameBoy_about_menu">About</span>
</div>
<div id="gfx">
<canvas id="mainCanvas"/>
<span id="title">GameBoy</span>
<span id="port_title">Online</span>
</div>
</div>
<div id="terminal" class="window">
<div id="terminal_output"/>
</div>

<script type="text/javascript">
var DEBUG_MESSAGES = false;
var DEBUG_WINDOWING = false;
window.onload = function () {
    windowingInitialize();

var xhr = new XMLHttpRequest();
xhr.open('GET', "{{site.baseurl}}{{page.type}}s/{{page.shortname}}/hello.gb", true);
xhr.overrideMimeType('text/plain; charset=x-user-defined')
//xhr.responseType = 'arraybuffer';

xhr.onload = function(e) {
  if (this.status == 200) {
    start(document.getElementById("mainCanvas"), this.response);
  }
};

xhr.send();
};
</script>

Way

Hello world
