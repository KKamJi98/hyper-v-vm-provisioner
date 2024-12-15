# 템플릿 VM 설정
$TemplateVHDX = "D:\Hyper-V-Template\k8s-node-template\node.vhdx"
$SwitchName = "MySwitch"
$BasePath = "D:\Hyper-V-VMs" # VM의 기본 경로
$VMs = @(
    @{ Name = "k8s-m1"; RAM = 4096MB; CPU = 2 },
    @{ Name = "k8s-m2"; RAM = 4096MB; CPU = 2 },
    @{ Name = "k8s-m3"; RAM = 4096MB; CPU = 2 },
    @{ Name = "k8s-w1"; RAM = 8192MB; CPU = 2 },
    @{ Name = "k8s-w2"; RAM = 8192MB; CPU = 2 }
)

# VM 생성 루프
foreach ($VM in $VMs) {
    # 각 VM의 디렉토리 및 VHD 경로 설정
    $VMPath = Join-Path -Path $BasePath -ChildPath $VM.Name
    $VHDPath = Join-Path -Path $VMPath -ChildPath "$($VM.Name).vhdx"

    # 디렉토리 생성
    New-Item -ItemType Directory -Path $VMPath -Force

    # 템플릿 VHDX 복사
    Copy-Item -Path $TemplateVHDX -Destination $VHDPath -Force

    # 하드디스크 용량 조정 (예: 60GB)
    Resize-VHD -Path $VHDPath -SizeBytes 30GB

    # 새 VM 생성
    New-VM -Name $VM.Name -MemoryStartupBytes $VM.RAM -Generation 2 -VHDPath $VHDPath -Path $VMPath

    # 보안 부팅 비활성화
    Set-VMFirmware -VMName $VM.Name -EnableSecureBoot Off

    # # 네트워크 연결
    # Add-VMNetworkAdapter -VMName $VM.Name -SwitchName $SwitchName

    # 기존 네트워크 어댑터 설정 변경
    $NetworkAdapters = Get-VMNetworkAdapter -VMName $VM.Name
    if ($NetworkAdapters.Count -gt 0) {
        # 첫 번째 네트워크 어댑터를 MySwitch에 연결
        Connect-VMNetworkAdapter -VMName $VM.Name -SwitchName $SwitchName -Name $NetworkAdapters[0].Name
        Write-Host "Connected existing network adapter of $($VM.Name) to $SwitchName."
    } else {
        Write-Host "No existing network adapter found for $($VM.Name). Skipping network configuration."
    }

    # CPU 설정
    Set-VMProcessor -VMName $VM.Name -Count $VM.CPU

    # 동적 메모리 비활성화
    Set-VMMemory -VMName $VM.Name -DynamicMemoryEnabled $false

    # VM 시작
    Start-VM -Name $VM.Name

    Write-Host "Created and started VM: $($VM.Name)"
}
