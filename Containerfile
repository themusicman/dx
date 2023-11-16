FROM gcr.io/projectsigstore/cosign:v1.13.0 as cosign-bin
FROM registry.fedoraproject.org/fedora-toolbox:39

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox or distrobox command" \
      summary="A cloud-native terminal experience" \
      maintainer="th3mus1cman@proton.me"

COPY extra-packages /

# Do some repo setup
RUN dnf install 'dnf-command(config-manager)'
RUN dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo

# Add the extra packages
RUN dnf update -y && \
    dnf upgrade -y && \
    grep -v '^#' /extra-packages | xargs dnf install -y
RUN rm /extra-packages

# TODO: make this better
RUN wget https://starship.rs/install.sh && chmod +x install.sh && ./install.sh -y && rm install.sh

# install cosign
COPY --from=cosign-bin /ko-app/cosign /usr/local/bin/cosign

# provider some convenience links to the host
RUN   ln -fs /bin/sh /usr/bin/sh && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/docker && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/flatpak && \ 
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/rpm-ostree && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/transactional-update
     
