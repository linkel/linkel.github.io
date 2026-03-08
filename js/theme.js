(function () {
  var STORAGE_KEY = "theme-preference";

  function getPreference() {
    var stored = localStorage.getItem(STORAGE_KEY);
    if (stored) return stored;
    return window.matchMedia("(prefers-color-scheme: dark)").matches
      ? "dark"
      : "light";
  }

  function applyTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme);
    var btn = document.getElementById("theme-toggle");
    if (btn) {
      btn.setAttribute("aria-label", theme === "dark" ? "Switch to light mode" : "Switch to dark mode");
      btn.textContent = theme === "dark" ? "light_mode" : "dark_mode";
    }
  }

  // Apply immediately to prevent flash
  applyTheme(getPreference());

  document.addEventListener("DOMContentLoaded", function () {
    applyTheme(getPreference());

    var btn = document.getElementById("theme-toggle");
    if (btn) {
      btn.addEventListener("click", function () {
        var current = document.documentElement.getAttribute("data-theme") || "light";
        var next = current === "dark" ? "light" : "dark";
        localStorage.setItem(STORAGE_KEY, next);
        applyTheme(next);
      });
    }

    // Obfuscated email (replaces jQuery usage)
    var emailEl = document.getElementById("email");
    if (emailEl) {
      var a = "kellylincode";
      a += "@";
      a += "gmail.com";
      emailEl.textContent = a;
    }

    // External links open in new tab
    document.querySelectorAll('a[href^="http"]').forEach(function (link) {
      if (link.hostname !== window.location.hostname) {
        link.setAttribute("target", "_blank");
        link.setAttribute("rel", "noopener");
      }
    });

    // Staggered fade-in for animated sections
    var sections = document.querySelectorAll(".fade-in");
    sections.forEach(function (el, i) {
      el.style.animationDelay = (i * 80) + "ms";
    });
  });
})();
