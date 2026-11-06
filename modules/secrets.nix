{ username, ... }:

{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age.sshKeyPaths = [
      "/home/${username}/.ssh/id_ed25519_personal"
    ];

    secrets."ssh/lambda-staging" = {
      owner = username;
      group = "users";
      mode = "0400";
      path = "/home/${username}/.ssh/lambda-staging";
    };

    secrets."ssh/lambda-prod" = {
      owner = username;
      group = "users";
      mode = "0400";
      path = "/home/${username}/.ssh/lambda-prod";
    };
  };
}
