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
user_pref("privacy.clearOnShutdown.history", false);
user_pref("privacy.clearOnShutdown_v2.historyFormDataAndDownloads", false);
// Enable DRM
user_pref("media.eme.enabled", true);
// Disable letterboxing
user_pref("privacy.resistFingerprinting.letterboxing", false);

// REMOVE USELESS FEATURES
// -----------------------------------------------
// Disable search engine suggestions in the urlbar
user_pref("browser.urlbar.suggest.engines", false);
// Disable container tabs
user_pref("privacy.userContext.enabled", false);
user_pref("privacy.userContext.ui.enabled", false);
// Don't save passwords
user_pref("signon.rememberSignons", false);

// USE FIREFOX-GNOME-THEME
// -----------------------------------------------
// Enable customChrome.css
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
// Set UI density to normal
user_pref("browser.uidensity", 0);
// Enable SVG context-propertes
user_pref("svg.context-properties.content.enabled", true);
// Disable private window dark theme
user_pref("browser.theme.dark-private-windows", false);
// Hide single tab
user_pref("gnomeTheme.hideSingleTab", true);
