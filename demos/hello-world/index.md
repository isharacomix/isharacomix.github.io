---
layout: post
title: Hello World!
type: demo
engine: gb
rom: hello.gb
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
<div id="gfx">
<canvas tabindex="0" id="mainCanvas"/>
</div>
</div>


<script type="text/javascript">
var DEBUG_MESSAGES = false;
var DEBUG_WINDOWING = false;
window.onload = function () {
    windowingInitialize();

var xhr = new XMLHttpRequest();
xhr.open('GET', "{{site.baseurl}}{{page.type}}s/{{page.shortname}}/{{page.rom}}", true);
xhr.overrideMimeType('text/plain; charset=x-user-defined')

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
