function fallbackCopyTextToClipboard(text) {
    var textArea = document.createElement("textarea");
    textArea.value = text;

    // Avoid scrolling to bottom
    textArea.style.top = "0";
    textArea.style.left = "0";
    textArea.style.position = "fixed";

    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();

    try {
        var successful = document.execCommand('copy');
        // var msg = successful ? 'successful' : 'unsuccessful';
        // console.log('Fallback: Copying text command was ' + msg);
    } catch (err) {
        // console.error('Fallback: Oops, unable to copy', err);
    }

    document.body.removeChild(textArea);
}

function copyTextToClipboard(text) {
    if (!navigator.clipboard) {
        fallbackCopyTextToClipboard(text);
        return;
    }
    return navigator.clipboard.writeText(text);
    // .then(function() {
    //     console.log('Async: Copying to clipboard was successful!');
    // }, function(err) {
    //     console.error('Async: Could not copy text: ', err);
    // });
}

function copyButton(btn) {
    label = btn.querySelector("#label");
    text = btn.querySelector("#text");
    copyTextToClipboard(text.innerText);
    if (label.innerHTML != "Copied"){
        originalHTML = label.innerHTML;
        label.innerHTML = "Copied";
        setTimeout(function(lbl, orig){
            return function(){
                lbl.innerHTML = orig;};}(label, originalHTML), 1000);
    }
}
