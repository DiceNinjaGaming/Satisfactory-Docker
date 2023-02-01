FROM phusion/baseimage:jammy-1.0.1

ENV DEBIAN_FRONTEND=noninteractive

# Download and register the Microsoft repository GPG keys
RUN apt-get update
RUN apt-get install -y wget apt-transport-https software-properties-common
RUN wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
RUN dpkg -i packages-microsoft-prod.deb

# Update and install misc packages
RUN apt-get update
RUN apt-get install --no-install-recommends --no-install-suggests -y \
    powershell lib32gcc-s1 curl ca-certificates locales supervisor zip

# Install SteamCMD
WORKDIR /steam
RUN wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
  && tar xvf steamcmd_linux.tar.gz

# Set up server folders
WORKDIR /app
RUN mkdir -p ./backups
RUN mkdir -p ./server
RUN mkdir -p ./logs

# Copy configs
COPY ./configs/supervisord.conf /etc

# Copy scripts
WORKDIR /scripts
COPY ./scripts/Entrypoint.ps1 .
COPY ./scripts/Start-Server.ps1 .
COPY ./scripts/Start-BackupService.ps1 .
COPY ./scripts/Start-UpdateService.ps1 .

# Set up game-specific variable defaults
ENV STEAM_APPID="1690800" \
    AUTO_PAUSE="true" \
    BACKUP_AUTOSAVE_AMOUNT="5" \
    BACKUP_AUTOSAVE_INTERVAL="300" \
    BACKUP_AUTOSAVE_ONDISCONNECT="true" \
    CRASH_REPORT="true" \
    DISABLE_SEASONAL_EVENTS="false" \
    # GAMECONFIGDIR="/config/gamefiles/FactoryGame/Saved" \
    # GAMESAVESDIR="/home/steam/.config/Epic/FactoryGame/Saved/SaveGames" \
    MAXOBJECTS="2162688" \
    MAXPLAYERS="4" \
    NETWORKQUALITY="3" \
    # PGID="1000" \
    # PUID="1000" \
    SERVERBEACONPORT="15000" \
    SERVERGAMEPORT="7777" \
    SERVERIP="0.0.0.0" \
    SERVERQUERYPORT="15777" \
    SKIPUPDATE="false" \
    STEAMBETA="false" \
    TIMEOUT="300"

# HEALTHCHECK CMD sv status ddns | grep run || exit 1

CMD pwsh /scripts/Entrypoint.ps1
