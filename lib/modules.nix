{ self, lib, ... }:

let
  inherit (builtins) attrValues pathExists concatLists typeOf readDir;
  inherit (lib) id mapAttrsToList filterAttrs nameValuePair mapAttrs;
  inherit (lib.strings) hasPrefix hasSuffix removeSuffix;
  inherit (self.attrs) mapFilterAttrs;
in
rec {
  mapModulesOn = dir: on: only: fn:
    mapFilterAttrs
      (n: v:
        v != null &&
        !(hasPrefix "_" n))
      (n: v:
        let
          path = dir + "/${n}";
        in

        if v == "directory" && pathExists (path + "/${on}")
        then
          nameValuePair n (fn (path + "/${on}"))
        else if v == "regular"
          && !only
          && n != on
          && hasSuffix ".nix" n
        then
          nameValuePair (removeSuffix ".nix" n) (fn path)
        else
          nameValuePair "" null
      )
      (readDir dir);


  # only import `on` files
  mapModulesOnOnly = dir: on: mapModulesOn dir on true;

  mapModules = dir: mapModulesOn dir "default.nix" false;

  mapModules' = dir: fn:
    attrValues (mapModules dir fn);

  mapModulesRecOn = dir: on: only: fn:
    mapFilterAttrs
      (n: v:
        v != null &&
        !(hasPrefix "_" n))
      (n: v:
        let path = dir + "/${n}"; in

        if v == "directory"
        then
          if pathExists (path + "/${on}") then
            nameValuePair (removeSuffix ".nix" n) (fn path)
          #{ name = "test"; value = pathExists (path + "/${on}"); }
          else
            nameValuePair n (mapModulesRecOn path on only fn)
        else if v == "regular"
          && !only
          && n != on && hasSuffix ".nix" n
        then
          nameValuePair (removeSuffix ".nix" n) (fn path)
        else
          nameValuePair "" null)
      (readDir dir);

  mapModulesRec = dir: mapModulesRecOn dir "default.nix" false;

  mapModulesRec' = dir: fn:
    let
      dirs =
        mapAttrsToList
          (k: _: "${dir}/${k}")
          (filterAttrs
            (n: v: v == "directory" && !(hasPrefix "_" n))
            (readDir dir));
      files = attrValues (mapModules dir id);
      paths = files ++ concatLists (map (d: mapModulesRec' d id) dirs);
    in
    map fn paths;

  callLamdasRec = set: arguments:
    let
      innerFun = value:
        let
          valueType = typeOf value;
        in
        if valueType == "set"
        then (callLamdasRec value arguments)
        else if valueType == "lambda"
        then (value arguments)
        else value;

    in
    mapAttrs (_name: value: (innerFun value)) set;


}
