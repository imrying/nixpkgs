{ buildGoModule
, fetchFromGitHub
, installShellFiles
, lib
, sqlcmd
, testers
}:

buildGoModule rec {
  pname = "sqlcmd";
  version = "0.15.3";

  src = fetchFromGitHub {
    repo = "go-sqlcmd";
    owner = "microsoft";
    rev = "v${version}";
    sha256 = "sha256-1CdZVh7pbupCNOE1ydgYEqX4rYo2LRddlNRNf0QjlN0=";
  };

  vendorSha256 = "sha256-6JfxKzYAjSQ9JFuFGDUZ0ALS1D7f2LK3bP0Fbl2ivo0=";
  proxyVendor = true;

  ldflags = [ "-s" "-w" "-X main.version=${version}" ];

  subPackages = [ "cmd/modern" ];

  nativeBuildInputs = [ installShellFiles ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  postInstall = ''
    mv $out/bin/modern $out/bin/sqlcmd

    installShellCompletion --cmd sqlcmd \
      --bash <($out/bin/sqlcmd completion bash) \
      --fish <($out/bin/sqlcmd completion fish) \
      --zsh <($out/bin/sqlcmd completion zsh)
  '';

  passthru.tests.version = testers.testVersion {
    package = sqlcmd;
    command = "sqlcmd --version";
    inherit version;
  };

  meta = {
    description = "A command line tool for working with Microsoft SQL Server, Azure SQL Database, and Azure Synapse";
    homepage = "https://github.com/microsoft/go-sqlcmd";
    changelog = "https://github.com/microsoft/go-sqlcmd/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ratsclub ];
  };
}
