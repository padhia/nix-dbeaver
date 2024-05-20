{ stdenv
, fetchurl
, makeDesktopItem
, makeWrapper
, autoPatchelfHook
, fontconfig
, freetype
, glib
, gtk3
, jdk
, lib
, xorg
, zlib
}:
stdenv.mkDerivation rec {
  pname   = "dbeaver";
  version = "24.0.5";

  desktopItem = makeDesktopItem {
    name        = "dbeaver";
    exec        = "dbeaver";
    icon        = "dbeaver";
    desktopName = "dbeaver";
    comment     = "SQL Integrated Development Environment";
    genericName = "SQL Integrated Development Environment";
    categories  = ["Development"];
  };

  buildInputs = [
    fontconfig
    freetype
    glib
    gtk3
    jdk
    xorg.libX11
    xorg.libXrender
    xorg.libXtst
    zlib
  ];

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
  ];

  src = fetchurl {
    url    = "https://dbeaver.io/files/${version}/dbeaver-ce-${version}-linux.gtk.x86_64-nojdk.tar.gz";
    sha256 = "sha256-q6VIr55hXn47kZrE2i6McEOfp2FBOvwB0CcUnRHFMZs=";
  };

  installPhase = ''
    # Create the directory where DBeaver will reside within the Nix store.
    mkdir -p $out/

    # Copy all the files from the build directory to the Nix store.
    cp -r . $out/dbeaver

    # The binaries will be automatically patched by autoPatchelfHook.
    # This adds necessary runtime dependencies to the ELF files.

    # Create a wrapper script for launching DBeaver.
    # - Sets Java path
    # - Sets library path for GTK and X11
    # - Sets GSettings schema path
    makeWrapper $out/dbeaver/dbeaver $out/bin/dbeaver \
      --prefix PATH : ${jdk}/bin \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [glib gtk3 xorg.libXtst]} \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH"

    # Create a directory for the desktop entry.
    mkdir -p $out/share/applications

    # Copy the generated desktop entry to the appropriate location.
    cp ${desktopItem}/share/applications/* $out/share/applications

    # Create a directory for storing the DBeaver icon.
    mkdir -p $out/share/pixmaps

    # Symlink the DBeaver icon to the standard location.
    ln -s $out/dbeaver/icon.xpm $out/share/pixmaps/dbeaver.xpm
  '';

  meta = with lib; {
    homepage        = "https://dbeaver.io/";
    description     = "Universal SQL Client for developers, DBA and analysts. Supports MySQL, PostgreSQL, MariaDB, SQLite, and more";
    longDescription = ''
      Multi-platform database tool for developers, SQL programmers, database
      administrators and analysts. Supports all popular databases: MySQL,
      PostgreSQL, MariaDB, SQLite, Oracle, DB2, SQL Server, Sybase, MS Access,
      Teradata, Firebird, Derby, etc.
    '';
    license     = licenses.asl20;
    platforms   = ["x86_64-linux"];
    maintainers = [maintainers.padhia];
  };
}
