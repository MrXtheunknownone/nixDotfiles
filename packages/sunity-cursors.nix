{ stdenvNoCC, fetchFromGitHub }:

# Sunity cursor theme — https://github.com/alvatip/Sunity-cursors
# Not in nixpkgs, so we package the prebuilt theme directories directly.
# Provides two themes: "Sunity-cursors" (dark) and "Sunity-cursors-white" (light).
stdenvNoCC.mkDerivation {
  pname = "sunity-cursors";
  version = "unstable-2024-09-29";

  src = fetchFromGitHub {
    owner = "alvatip";
    repo = "Sunity-cursors";
    rev = "919a16a3aab85102f530e991db8cfeec2963cf98";
    hash = "sha256-7aNHuPb4xLeFICxLciXjU7i8NUf0K9wzbkPrReOH/bo=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons
    cp -r Sunity-cursors Sunity-cursors-white $out/share/icons/
    runHook postInstall
  '';

  meta = {
    description = "Sunity cursor theme (based on Breeze and Radioactive)";
    homepage = "https://github.com/alvatip/Sunity-cursors";
  };
}
