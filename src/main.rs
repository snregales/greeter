use chrono::Local;
use sysinfo::{System, SystemExt};

fn main() {
    // Get the current date and time.
    let now = Local::now();

    println!("\nGreetings!");
    println!("Current Date: {}", now.format("%Y-%m-%d"));
    println!("Current Time: {}", now.format("%H:%M:%S"));

    // Initialize system info.
    let mut sys = System::new_all();
    sys.refresh_all();

    // Retrieve hostname (if available).
    if let Some(hostname) = sys.host_name() {
        println!("Hostname: {}", hostname);
    }

    let os_name = sys.name().unwrap_or_else(|| "Unknown OS".to_string());
    let os_version = sys
        .os_version()
        .unwrap_or_else(|| "Unknown Version".to_string());
    println!("Operating System: {} {}", os_name, os_version);

    // Retrieve system uptime.
    println!("System Uptime: {} seconds", sys.uptime());
}
