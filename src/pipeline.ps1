Set-Location -Path "feature_store"
./exec.ps1
Set-Location -Path "../predict"
python predict.py