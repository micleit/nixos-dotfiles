{
  lib,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "jupynium";
  version = "0.2.8";
  format = "wheel";

  src = python3Packages.fetchPypi {
    inherit pname version format;
    dist = "py3";
    python = "py3";
    sha256 = "1cca97bf70e7f9977dc52d327ab3af99bba49802796ee8b63f5f1dae3115996c";
  };

  propagatedBuildInputs = with python3Packages; [
    coloredlogs
    gitpython
    persist-queue
    platformdirs
    psutil
    pynvim
    selenium
    verboselogs
  ];

  doCheck = false;

  meta = with lib; {
    description = "Control Jupyter Notebook with Neovim";
    homepage = "https://github.com/kiyoon/jupynium.nvim";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
