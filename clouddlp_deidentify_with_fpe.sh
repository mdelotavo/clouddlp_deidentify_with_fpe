# https://cloud.google.com/kms/docs/quickstart
# https://github.com/GoogleCloudPlatform/python-docs-samples/blob/master/dlp/deid.py
# https://cloud.google.com/docs/authentication/production

gcloud kms keyrings create clouddlp --location global

gcloud kms keys create dlp_deidentify_fpe --location global \
  --keyring clouddlp --purpose encryption  

gcloud kms keys list --location global --keyring clouddlp

openssl enc -aes-128-cbc -k secret -P -md sha1 > myaeskey.dat

# 32 bytes -> 31 bytes
grep key myaeskey.dat | cut -d '=' -f 2 | sed s'/.$//' > key

gcloud kms encrypt \
  --location=global  \
  --keyring=clouddlp \
  --key=dlp_deidentify_fpe \
  --plaintext-file=key \
  --ciphertext-file=key.enc

base64 key.enc -w 0; echo
# OUT: CiQAHdewvyf31WW6LD+dnvCSfa7dg71GS5Md9lg15jaQDVoDVz4SSACC925rfz6f+/0olcmAmVivA/EIW2J+4jxwONYnd46Vo5g3MyrP1/R49z2bj05UPz7O63Y/gud9bNvBsv1YAbmzypuPr9Eitw==

# YOUR_PROJECT_ID=set_this_value
# YOUR_KEY_NAME=set_this_value
YOUR_WRAPPED_KEY=CiQAHdewvyf31WW6LD+dnvCSfa7dg71GS5Md9lg15jaQDVoDVz4SSACC925rfz6f+/0olcmAmVivA/EIW2J+4jxwONYnd46Vo5g3MyrP1/R49z2bj05UPz7O63Y/gud9bNvBsv1YAbmzypuPr9Eitw==

pip install --upgrade google-cloud-dlp

python deidentify_with_fpe.py deid_fpe \
  -s '[TOKEN]' \
  ${YOUR_PROJECT_ID} \
  'My name is Alicia Abernathy, and my email address is aabernathy@example.com.' \
  ${YOUR_KEY_NAME} \
  ${YOUR_WRAPPED_KEY}
# OUT: My name is [TOKEN](6):MI4dGh [TOKEN](9):V0c0LsVb8, and my email address is aabernathy@example.com.

python deidentify_with_fpe.py reid_fpe \
  ${YOUR_PROJECT_ID} \
  'My name is [TOKEN](6):MI4dGh [TOKEN](9):V0c0LsVb8, and my email address is aabernathy@example.com.' \
  '[TOKEN]' \
  ${KEY_NAME} \
  ${YOUR_WRAPPED_KEY}
# OUT: My name is Alicia Abernathy, and my email address is aabernathy@example.com.
