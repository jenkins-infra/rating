// @author Alan Harder
var crumb = { wrap: function() { } };

function loaddata(link) {
  var script = document.createElement('SCRIPT');
  script.type = 'text/javascript';
  script.src = 'http://jenkins-ci.org/rate/result.php';
  script.onload = function() { do_loaddata(); }
  script.onreadystatechange = function() { // For IE
    if (this.readyState=='loaded' || this.readyState=='complete') do_loaddata();
  }
  document.getElementById('head').appendChild(script);
  link.style.display = 'none';
  document.getElementById('ratings').style.display = 'block';
  return false;
}

function health(nm,sz,ver,rate) {
  return '<img src="http://ci.jenkins-ci.org/images/' + sz + 'x' + sz + '/health-' + nm
       + '.gif" width="' + sz + '" height="' + sz + '" onclick="rate(\'' + ver
       + '\',' + rate + ')" class="rate" alt=""/>';
}

function do_loaddata() {
  var r, v, j, first = true, div1, div2, txt;
  for (var anchors = document.getElementsByTagName('A'), i = 0; i < anchors.length; i++) {
    if (anchors[i].name.charAt(0) != 'v') continue;
    if (first) { first = false; continue; } // Skip first anchor (for upcoming release)
    r = data[v = anchors[i].name.substring(1)];
    div1 = document.createElement('DIV');
    div1.className = 'rate-outer';
    div2 = document.createElement('DIV');
    div2.className = 'rate-offset';
    txt = (r && r[0] ? r[0] + ' ' : '') + health('80plus',(r && r[0] ? 32 : 16),v,1)
        + (r && r[1] ? r[1] + ' ' : '') + health('40to59',(r && r[1] ? 32 : 16),v,0)
        + (r && r[2] ? r[2] + ' ' : '') + health('00to19',(r && r[2] ? 32 : 16),v,-1);
    if (r && r.length > 3) {
      txt += '<span class="related-issues">Related issues: ';
      for (j = 3; j < r.length; j++)
        txt += '<a href="http://jenkins-ci.org/issue/' + r[j] + '">JENKINS-' + r[j] + '</a> ';
      txt += '</span>';
    }
    div2.innerHTML = txt;
    div1.appendChild(div2);
    insertAfter(anchors[i].parentNode,div1);
  }
}

function insertAfter(anchor,node) {
  anchor.parentNode.insertBefore(node,anchor.nextSibling);
}

function rate(version,rating) {
  var issue = (rating <= 0) ? prompt('Optionally provide issue number causing trouble:','') : '';
  if (issue==null) return; // Cancelled
  var script = document.createElement('SCRIPT');
  script.type = 'text/javascript';
  script.src = 'http://jenkins-ci.org/rate/submit.php?version='
    + encodeURIComponent(version) + '&rating=' + rating + '&issue=' + encodeURIComponent(issue);
  script.onload = function() { alert('Thanks!'); location.reload(); }
  script.onreadystatechange = function() { // For IE
    if (this.readyState=='loaded' || this.readyState=='complete') {
      alert('Thanks!'); location.reload();
    }
  }
  document.getElementById('head').appendChild(script);
}

