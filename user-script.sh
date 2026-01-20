az account set --subscription cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078
SCOPE="$(az group show -n rg-tf-lab --query id -o tsv | tr -d '\r')"

students=(
  "michael-matejo",
  "schuetz-klaus",
  "mitterhuber-lea",
  "wolfer-philipp",
  "neumayer-herbert",
)

for s in "${students[@]}"; do
  echo "=== Creating SP for $s ==="

  CREDS=$(az ad sp create-for-rbac \
    --name "sp-student-$s" \
    --skip-assignment \
    -o json)

  APP_ID=$(echo "$CREDS" | jq -r .appId)
  SP_OBJECT_ID="$(az ad sp show --id "$APP_ID" --query id -o tsv | tr -d '\r')"

  az role assignment create \
    --assignee-object-id "$SP_OBJECT_ID" \
    --assignee-principal-type ServicePrincipal \
    --role "Contributor" \
    --scope "$SCOPE" \
    -o none

  # save credentials per student (LOCK THESE FILES DOWN)
  echo "$CREDS" > "student-$s-creds.json"

  echo "✔ $s done"
done
