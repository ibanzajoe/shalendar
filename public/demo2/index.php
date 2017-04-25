<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <title></title>
    <link rel="stylesheet" type="text/css" href="plugin/css/style.css">
    <link rel="stylesheet" type="text/css" href="css/demo.css">
    <script type="text/javascript" src="js/jquery-1.6.1.min.js"></script>
    <script type="text/javascript" src="plugin/jquery-jplayer/jquery.jplayer.js"></script>
    <script type="text/javascript" src="plugin/ttw-music-player-min.js"></script>
    <script type="text/javascript" src="js/myplaylist.js"></script>

    <link type="text/css" rel="stylesheet" href="http://www.bcat.eu/data/demo/jquery-bg-switcher/fullscreen/css/style.css" media="all" />
    <script type="text/javascript" src="http://www.bcat.eu/data/demo/jquery-bg-switcher/fullscreen/js/jquery.bcat.bgswitcher.min.js"></script>

</head>
<body>


    <div id="bg-body"></div>
    <div id="player"></div>

    <script type="text/javascript">
    $(document).ready(function() {
        $('#player').ttwMusicPlayer(myPlaylist, {
            autoPlay:true, 
            description:'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce id tortor nisi. Aenean sodales diam ac lacus elementum scelerisque. Suspendisse a dui vitae lacus faucibus venenatis vel id nisl. Proin orci ante, ultricies nec interdum at, iaculis venenatis nulla. ',
            jPlayer:{
                    swfPath:'plugin/jquery-jplayer' //You need to override the default swf path any time the directory structure changes
                }
            });

        var srcBgArray = ["http://www.bcat.eu/data/demo/jquery-bg-switcher/fullscreen/images/img-slider-1.jpg","./images/img-slider-2.jpg","./images/img-slider-3.jpg","./images/img-slider-4.jpg"];
        $('#bg-body').bcatBGSwitcher({
            urls: srcBgArray,
            alt: 'Full screen background image',
            links: true
        });
    });
    </script>

    <div id="title"></div>
    <a href="http://www.codebasehero.com/download?file=music-player" id="download">Download Here</a>
</body>
</html>