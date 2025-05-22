// CONVENIENCE
// -----------------------------------------------
// Enable urlbar searching
user_pref("keyword.enabled", true); 
user_pref("browser.search.suggest.enabled", true);
user_pref("browser.urlbar.suggest.searches", true);
// Enable session restore
user_pref("browser.startup.page", 3);
// Remember the file download location
user_pref("browser.download.useDownloadDir", true);
// Don't clear history
user_pref("privacy.clearOnShutdown_v2.browsingHistoryAndDownloads", false);

// REMOVE USELESS FEATURES
// -----------------------------------------------
// Disable search engine suggestions in the urlbar
user_pref("browser.urlbar.suggest.engines", false);
// Disable container tabs
user_pref("privacy.userContext.enabled", false);
user_pref("privacy.userContext.ui.enabled", false);
// Don't save passwords
user_pref("signon.rememberSignons", false);
