{ nixpkgs, declInput }: let pkgs = import nixpkgs {}; in {
  jobsets = pkgs.runCommand "spec.json" {} ''
    cat <<EOF
    ${builtins.toXML declInput}
    EOF
    cat > $out <<EOF
    {
        "exitcode-process": {
            "enabled": 1,
            "hidden": false,
            "description": "exitcode-process",
            "nixexprinput": "exitcode-process",
            "nixexprpath": "ci/ci.nix",
            "checkinterval": 300,
            "schedulingshares": 1,
            "enableemail": false,
            "emailoverride": "",
            "keepnr": 5,
            "inputs": {
                "exitcode-process": { "type": "git", "value": "https://github.com/qfpl/exitcode-process", "emailresponsible": false },
                "nixpkgs": { "type": "git", "value": "https://github.com/NixOS/nixpkgs.git release-18.09", "emailresponsible": false }
            }
        }
    }
    EOF
  '';
}
