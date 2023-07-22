{ pkgs, ... }:
{
  languages = {
    nix = {
      enable = true;
    };

    elixir = {
      enable = true;
      package = pkgs.beam.packages.erlangR25.elixir;
    };
  };

  packages = [
    pkgs.elixir-ls
    pkgs.inotify-tools
  ];

  scripts.check.exec = ''
    echo "📋 Checking formatting..."
    mix format --check-formatted
    format_result=$?
    echo "🧪 Running tests..."
    mix test
    test_result=$?
    exit $((format_result + test_result))
  '';

  scripts.run.exec = ''
    while [[ $# -gt 0 ]]; do
      case $1 in
        -i|--interactive)
          interactive=yes
          shift
          ;;
      esac
    done

    if [[ $interactive == yes ]]; then
      iex -S mix phx.server
    else
      mix phx.server
    fi
  '';

  scripts.setup.exec = "mix setup";

  enterShell = ''
    green='\033[0;32m'
    reset_color='\033[0m'
    echo "🐞 Welcome to Humbug 🐞"
    echo ""
    echo "Useful commands:"
    echo -e " ► ''${green}setup''${reset_color}: Fetch all dependencies."
    echo -e " ► ''${green}check''${reset_color}: Run format check and tests."
    echo -e " ► ''${green}run''${reset_color}:   Start the server, use -i/--interactive to start it in an interative repl."
    echo -e "          Start the database with ''${green}devenv up''${reset_color} or ''${green}start-postgres''${reset_color} first."
    echo ""
  '';

  services = {
    postgres = {
      enable = true;
      initialDatabases = [{ name = "humbug_dev"; }];
      initialScript = ''
        CREATE USER postgres WITH PASSWORD 'postgres' CREATEDB;
        ALTER DATABASE humbug_dev OWNER TO postgres;
      '';
    };
  };
}
