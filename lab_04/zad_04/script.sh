#!/bin/bash

VOLUME_NAME="all_volumes"
ENCRYPTED_ARCHIVE="volume_backup.gpg"
TEMP_TAR="volume.tar"

read -rp "Encrypt[e]/Decrypt[d]" ACTION

encrypt() {
  docker run --rm -v "$VOLUME_NAME":/volume alpine sh -c \
  "tar cvf - -C /volume ." > "$TEMP_TAR"

  echo "Podaj hasło, które zostanie użyte do szyfrowania i odszyfrowania:"
  read -rsp "Hasło: " PASSWD
  echo

  echo "Szyfruję archiwum..."
  echo "$PASSWD" | gpg --batch --yes --passphrase-fd 0 -c "$TEMP_TAR"

  mv "${TEMP_TAR}.gpg" "$ENCRYPTED_ARCHIVE"
  rm "$TEMP_TAR"
  echo "Wolumin został zaszyfrowany i zapisany jako: $ENCRYPTED_ARCHIVE"
}

decrypt() {
  read -rsp "Hasło: " PASSWD
  echo

  echo "Odszyfrowywanie archiwum..."
  echo "$PASSWD" | gpg --batch --yes --passphrase-fd 0 -o "$TEMP_TAR" -d "$ENCRYPTED_ARCHIVE"

  echo "Wypakowywanie odszyfrowanego archiwum do woluminu..."
  docker run --rm -v "$VOLUME_NAME":/volume -v "$(pwd)":/backup alpine sh -c \
    "tar xvf /backup/$TEMP_TAR -C /volume"
  rm "$TEMP_TAR"
}

if [[ "$ACTION" == "e" ]];
then
  encrypt
else
  decrypt
fi

