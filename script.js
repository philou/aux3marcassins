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

function hideTab(tabId) {
  var tabContent = document.getElementById(tabId);
  tabContent.style.display = 'none';
  var tab = document.getElementById(tabId + 'Tab');
  tab.setAttribute('class', '');
}

function showTab(tabId) {
  var tabContent = document.getElementById(tabId);
  tabContent.style.display = 'block';
  var tab = document.getElementById(tabId + 'Tab');
  tab.setAttribute('class', 'current');
}

function changeTab(tabId) {
  var tabs = getElementByAttr(document,'class','tabContent');
  var i;
  for(i = 0; i < tabs.length; ++i) {
    hideTab(tabs[i].id);
  }
  showTab(tabId);
}
