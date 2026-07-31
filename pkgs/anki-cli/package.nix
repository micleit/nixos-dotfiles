{
  lib,
  python3Packages,
  fetchFromGitHub,
  fsrs,
}:
python3Packages.buildPythonApplication rec {
  pname = "anki-cli";
  version = "0.1.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ubermenchh";
    repo = "anki-cli";
    rev = "4d20280ad996c34ec724267598175d28012be787";
    sha256 = "0ifzfkpb8z0cqyv4w2dmgz99plc487glav11bvg9rhvp1mpch3l7";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  propagatedBuildInputs = with python3Packages; [
    click
    rich
    pydantic
    fsrs
    httpx
    betterproto
    pyperclip
    markdownify
    textual
    prompt-toolkit
  ];

  doCheck = false;

  meta = with lib; {
    description = "Hybrid Anki CLI for humans and agents";
    homepage = "https://github.com/ubermenchh/anki-cli";
    license = licenses.mit;
    mainProgram = "anki";
    platforms = platforms.unix;
  };
}
