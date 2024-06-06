window.onload = function() {
    var canvas = document.getElementsByTagName("canvas");
    for (var i = 0; i < canvas.length; i++) {
        ProcessingInstruction(canvas[i], canvas[i].previousElementSibling.textContent);
    }
};