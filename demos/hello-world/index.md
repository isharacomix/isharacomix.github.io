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
<div id="gfx">
<canvas id="mainCanvas"></canvas>
<span id="title">GameBoy</span>
<span id="port_title">Online</span>
</div>
</div>

 <script type="text/javascript">
var DEBUG_MESSAGES = false;
var DEBUG_WINDOWING = false;
window.onload = function () {
windowingInitialize();
start($("#mainCanvas"),"{{site.baseurl}}{{page.type}}s/{{page.shortname}}/hello.gb");
}
</script>

Way

Hello world
