# 템플릿 VM 설정
$BasePath = "D:\Hyper-V-VMs" # VM의 기본 경로
$VMs = @(
    @{ Name = "k8s-m1" },
    @{ Name = "k8s-m2" },
    @{ Name = "k8s-m3" },
    @{ Name = "k8s-w1" },
    @{ Name = "k8s-w2" }
)

# VM 삭제 루프
foreach ($VM in $VMs) {
    $VMName = $VM.Name
    $VMPath = Join-Path -Path $BasePath -ChildPath $VMName

    # VM 존재 여부 확인
    $ExistingVM = Get-VM -Name $VMName -ErrorAction SilentlyContinue

    if ($ExistingVM) {
        # VM 중지
        Stop-VM -Name $VMName -Force -ErrorAction SilentlyContinue

        # VM 삭제
        Remove-VM -Name $VMName -Force
        Write-Host "Deleted VM: $VMName"
    } else {
        Write-Host "VM does not exist: $VMName"
    }

    # VM 디렉토리 삭제
    if (Test-Path -Path $VMPath) {
        Remove-Item -Path $VMPath -Recurse -Force
        Write-Host "Deleted VM directory: $VMPath"
    } else {
        Write-Host "VM directory does not exist: $VMPath"
    }
}
