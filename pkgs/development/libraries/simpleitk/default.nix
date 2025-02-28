{ lib
, stdenv
, fetchFromGitHub
, cmake
, swig4
, lua
, elastix
, itk
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "simpleitk";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "SimpleITK";
    repo = "SimpleITK";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-SJSFJEFu1qKowX5/98MslN7GFDS8aF5+EKkQ2983Azg=";
  };

  nativeBuildInputs = [
    cmake
    swig4
  ];
  buildInputs = [
    elastix
    lua
    itk
  ];

  # 2.0.0: linker error building examples
  cmakeFlags = [
    "-DBUILD_EXAMPLES=OFF"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DSimpleITK_USE_ELASTIX=ON"
  ];

  meta = with lib; {
    homepage = "https://www.simpleitk.org";
    description = "Simplified interface to ITK";
    changelog = "https://github.com/SimpleITK/SimpleITK/releases/tag/v${finalAttrs.version}";
    maintainers = with maintainers; [ bcdarwin ];
    platforms = platforms.linux;
    license = licenses.asl20;
  };
})
