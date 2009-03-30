function getElementByAttr(e,attr,value) {
  var tab = [];
  if (e.getAttribute && e.getAttribute(attr)==value)
    tab.push(e);

  var n = e.firstChild;
  if (n==null || typeof n=='undefined') return tab;
  do
  {
    var tab2 = getElementByAttr(n,attr,value);
    tab = tab.concat(tab2);
  }while((n = n.nextSibling)!=null)
  return tab;
}

function changeTab(tabId) {
  var tabs = getElementByAttr(document,'class','tabContent');
  var i;
  for(i = 0; i < tabs.length; ++i) {
    tabs[i].style.display = 'none';
  }

  var newTab = document.getElementById(tabId);
  newTab.style.display = 'block';
}
