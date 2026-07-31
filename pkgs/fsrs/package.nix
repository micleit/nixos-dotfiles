{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
  typing-extensions,
}:
buildPythonPackage rec {
  pname = "fsrs";
  version = "6.3.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "1jhmddp5ni0g63xzv7xjw6jcb6pbmm69xvxzdspnn9lpdc2wdia3";
  };

  build-system = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    typing-extensions
  ];

  doCheck = false;

  meta = with lib; {
    description = "Free Spaced Repetition Scheduler";
    homepage = "https://github.com/open-spaced-repetition/py-fsrs";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
