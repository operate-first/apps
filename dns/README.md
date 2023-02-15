# Google Cloud DNS configuration

This repo contains dumps of the Google Cloud DNS hosted zones. It could be updated manually using `for z in $(cat zones.txt); do; docker run --rm -v$(pwd):/mnt:z --volumes-from gcloud-config gcr.io/google.com/cloudsdktool/google-cloud-cli gcloud dns record-sets export /mnt/$z.zone --zone=$z --zone-file-format; done`

Make sure you authenticated to Google Cloud using `docker run -ti --name gcloud-config gcr.io/google.com/cloudsdktool/google-cloud-cli gcloud auth login`.
