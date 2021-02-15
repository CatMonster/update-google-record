#!/bin/bash
usage() {
  echo "Usage: $0 [-s json_config]" 1>&2;
  exit 1;
}

#Getting params
while getopts ":s:" o; do
  case "${o}" in
    s)
      s=${OPTARG}
        ;;
    *)
      usage
        ;;
  esac
done
shift $((OPTIND-1))

if [ -z "${s}" ]; then
  usage
fi

#Reading values from json config
username=$(jq -r '.google.username' $s)
password=$(jq -r '.google.password' $s)
hostname=$(jq -r '.google.hostname' $s)

#Getting current record values and cleaning
public_ip=$(curl https://api.ipify.org)
current_domain_ip=$(dig +short ${hostname} @8.8.8.8)

#Updating
if [[ "$public_ip" != "$current_domain_ip" && -n "$public_ip" && -n "$current_domain_ip" ]]; then
  curl -s "https://${username}:${password}@domains.google.com/nic/update?hostname=${hostname}&myip=${public_ip}"
fi
