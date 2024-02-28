{
  fetchurl,
  stdenv,
  lib,
  binutils-unwrapped,
  xz,
  gnutar,
  file,
  glibc,
  glib,
  nss,
  nspr,
  atk,
  at-spi2-atk,
  xorg,
  cups,
  dbus,
  expat,
  libdrm,
  libxkbcommon,
  gtk3,
  pango,
  cairo,
  gdk-pixbuf,
  mesa,
  alsa-lib,
  at-spi2-core,
  libuuid,
  systemd,
}: let
  version = "98.0.1108.62";
in
  stdenv.mkDerivation {
    name = "microsoft-edge-stable-${version}";

    src = fetchurl {
      url = "https://sourceforge.net/projects/makulu/files/stable/packages/microsoft-edge-stable_98.0.1108.62-1_amd64.deb/download";
      sha256 = "sha256-GA6ki94+1JK8lxLb7SwWKVdpaMwcxaXX8jda9suzuCc=";
    };

    unpackCmd = "${binutils-unwrapped}/bin/ar p $src data.tar.xz | ${xz}/bin/xz -dc | ${gnutar}/bin/tar -xf -";
    sourceRoot = ".";

    dontPatch = true;
    dontConfigure = true;
    dontPatchELF = true;

    buildPhase = let
      libPath = {
        msedge = lib.makeLibraryPath [
          glibc
          glib
          nss
          nspr
          atk
          at-spi2-atk
          xorg.libX11
          xorg.libxcb
          cups.lib
          dbus.lib
          expat
          libdrm
          xorg.libXcomposite
          xorg.libXdamage
          xorg.libXext
          xorg.libXfixes
          xorg.libXrandr
          libxkbcommon
          gtk3
          pango
          cairo
          gdk-pixbuf
          mesa
          alsa-lib
          at-spi2-core
          xorg.libxshmfence
          systemd
        ];
        naclHelper = lib.makeLibraryPath [
          glib
          nspr
          atk
          libdrm
          xorg.libxcb
          mesa
          xorg.libX11
          xorg.libXext
          dbus.lib
          libxkbcommon
        ];
        libwidevinecdm = lib.makeLibraryPath [
          glib
          nss
          nspr
        ];
        libGLESv2 = lib.makeLibraryPath [
          xorg.libX11
          xorg.libXext
          xorg.libxcb
        ];
        libsmartscreen = lib.makeLibraryPath [
          libuuid
          stdenv.cc.cc.lib
        ];
        libsmartscreenn = lib.makeLibraryPath [
          libuuid
        ];
        liboneauth = lib.makeLibraryPath [
          libuuid
          xorg.libX11
        ];
      };
    in ''
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${libPath.msedge}" \
        opt/microsoft/msedge/msedge

      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        opt/microsoft/msedge/msedge-sandbox

      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        opt/microsoft/msedge/msedge_crashpad_handler

      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${libPath.naclHelper}" \
        opt/microsoft/msedge/nacl_helper

      patchelf \
        --set-rpath "${libPath.libwidevinecdm}" \
        opt/microsoft/msedge/WidevineCdm/_platform_specific/linux_x64/libwidevinecdm.so

      patchelf \
        --set-rpath "${libPath.libGLESv2}" \
        opt/microsoft/msedge/libGLESv2.so

      patchelf \
        --set-rpath "${libPath.libsmartscreen}" \
        opt/microsoft/msedge/libsmartscreen.so

      patchelf \
        --set-rpath "${libPath.libsmartscreenn}" \
        opt/microsoft/msedge/libsmartscreenn.so

      patchelf \
        --set-rpath "${libPath.liboneauth}" \
        opt/microsoft/msedge/liboneauth.so
    '';

    installPhase = ''
      mkdir -p $out
      cp -R opt usr/bin usr/share $out

      ln -sf $out/opt/microsoft/msedge/microsoft-edge $out/bin/microsoft-edge

      rm -rf $out/share/doc
      rm -rf $out/opt/microsoft/msedge/cron

      for icon in '16' '24' '32' '48' '64' '128' '256'
      do
        ${"icon_source=$out/opt/microsoft/msedge/product_logo_\${icon}.png"}
        ${"icon_target=$out/share/icons/hicolor/\${icon}x\${icon}/apps"}
        mkdir -p $icon_target
        cp $icon_source $icon_target/microsoft-edge.png
      done

      substituteInPlace $out/share/applications/microsoft-edge.desktop \
        --replace /usr/bin/microsoft-edge-stable $out/bin/microsoft-edge

      substituteInPlace $out/share/gnome-control-center/default-apps/microsoft-edge.xml \
        --replace /opt/microsoft/msedge $out/opt/microsoft/msedge

      substituteInPlace $out/share/menu/microsoft-edge.menu \
        --replace /opt/microsoft/msedge $out/opt/microsoft/msedge

      substituteInPlace $out/opt/microsoft/msedge/xdg-mime \
        --replace "''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}" "''${XDG_DATA_DIRS:-/run/current-system/sw/share}" \
        --replace "xdg_system_dirs=/usr/local/share/:/usr/share/" "xdg_system_dirs=/run/current-system/sw/share/" \
        --replace /usr/bin/file ${file}/bin/file

      substituteInPlace $out/opt/microsoft/msedge/default-app-block \
        --replace /opt/microsoft/msedge $out/opt/microsoft/msedge

      substituteInPlace $out/opt/microsoft/msedge/xdg-settings \
        --replace "''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}" "''${XDG_DATA_DIRS:-/run/current-system/sw/share}" \
        --replace "''${XDG_CONFIG_DIRS:-/etc/xdg}" "''${XDG_CONFIG_DIRS:-/run/current-system/sw/etc/xdg}"
    '';

    meta = with lib; {
      homepage = "https://www.microsoft.com/en-us/edge";
      description = "The web browser from Microsoft";
      license = licenses.unfree;
      platforms = ["x86_64-linux"];
      maintainers = with maintainers; [zanculmarktum kuwii];
    };
  }
