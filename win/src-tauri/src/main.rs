// Buzz desktop entrypoint. Tauri 2 ships the Next.js web app inside a system WebView
// (WebView2 on Windows, WebKit on macOS, WebKitGTK on Linux). No Electron, no
// embedded Chromium — the installer stays under ~10 MB.

#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
