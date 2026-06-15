{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age.sshKeyPaths = [
      "/home/yoran/.ssh/id_ed25519_personal"
    ];

    secrets."ssh/lambda-staging" = {
      owner = "yoran";
      group = "users";
      mode = "0400";
      path = "/home/yoran/.ssh/lambda-staging";
    };

    secrets."ssh/lambda-prod" = {
      owner = "yoran";
      group = "users";
      mode = "0400";
      path = "/home/yoran/.ssh/lambda-prod";
    };
  };
}
