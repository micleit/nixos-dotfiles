{
  lib,
  python3Packages,
}:
python3Packages.buildPythonApplication {
  pname = "substack-rss";
  version = "0.1.0";

  src = ./.;

  pyproject = true;
  build-system = with python3Packages; [
    setuptools
  ];

  propagatedBuildInputs = with python3Packages; [
    python-telegram-bot
    feedgen
    requests
    beautifulsoup4
    markdownify
  ];

  # Disable tests since we do not configure setuptools tests
  doCheck = false;

  meta = with lib; {
    description = "Telegram Bot to parse Substack posts and expose them as a sanitized RSS feed";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
